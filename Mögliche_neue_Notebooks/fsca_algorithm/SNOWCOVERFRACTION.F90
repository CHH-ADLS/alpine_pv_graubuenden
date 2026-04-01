!--------------------------------------------------------------------------
! Compute Snow covered fraction fSCA for a coarse grid cell 
!      - tanh functional form for fSCA as in Helbig et al., 2015
!      - parameterized standard deviation of snow depth for fSCA_season using Helbig et al., 2015, 2021
!      - parameterized standard deviation of snow depth for fSCA_newsnow and slope angles = 0 using Egli and Jonas, 2009
!      - a snow depth/SWE history at each grid cell in the season originally suggested from Jan Magnusson
! Author: Nora Helbig & Michael Schirmer & Jan Magnusson
!--------------------------------------------------------------------------

subroutine SNOWCOVERFRACTION(fsnow_n,snowdepth_n,SWEtmp,swehist_n,swemin_n,swemax_n,snowdepthhist_n,snowdepthmin_n, &
                              snowdepthmax_n,slopemu_n,xi_n,Ld_n)

implicit none

integer :: &
  iabsmin,iabsmax,           &! Indices of extrema found in SWEbuffer and applied to snow depth buffer
  irecentmin,                &! Indices of extrema found in SWEbuffer and applied to snow depth buffer
  iloop                       ! do loop index

real*8, intent(in) :: &
  snowdepth_n,               &! Snow depth (m)
  SWEtmp                      ! Temporary snow water equivalent for fSCA calculation (kg/m^2)

real*8, intent(in) :: &
  xi_n,                      &! terrain correlation length (cf. Helbig et al, 2021)
  slopemu_n,                 &! squared slope related parameter (cf. Helbig et al, 2021)
  Ld_n                        ! Coarse-grid cell size             

real*8, intent(inout) :: &
  fsnow_n,                   &! Snow cover fraction fSCA
  swehist_n(14),             &! history of snow water equivalent (SWE) during last 14 days (kg/m^2)
  snowdepthhist_n(14),       &! history of snow depth during last 14 days (m)
  snowdepthmin_n,            &! Min snow depth at time step swemin(m)
  snowdepthmax_n,            &! Max snow depth at time step swemax (m)
  swemin_n,                  &! Min swe during the season (mm)
  swemax_n                    ! Max swe during the season (mm)

real*8 :: &
  sd_snowdepth0,             &! Parameterized standard deviation of snow depths in a grid cell
  sd_snowdepth1,             &! Standard deviation parameter
  sd_snowdepth2,             &! Standard deviation parameter
  sd_snowdepth3,             &! Standard deviation parameter
  snowdepth_threshold,       &! Snow depth threshold for setting fsnow to zero
  dsnowdepth,                &! Shange in snow depth in past 14 days (m)
  dsnowdepthmax,             &! Maximum change in snow depth in past 14 days (m)
  dsnowdepth_recent,         &! Recent change in snow depth (m)
  SWEbuffer(15),             &! Buffer with 14 day history of SWE plus hourly current SWEtmp
  snowdepthbuffer(15),       &! Buffer with 14 day history of snow depth plus hourly current snow depth
  diffSWEbuffer(14),         &! Difference betwen entries in SWEbuffer
  snowdepthmin_buffer,       &! Absolute minimum of snow depth within the buffer
  snowdepthmax_buffer,       &! Absolute maximum of snow depth within the buffer
  snowdepthmin_recent,       &! Recent minimum of snow depth within the buffer
  fsnow_season,              &! Seasonal fSCA
  fsnow_nsnow,               &! New snow fSCA
  fsnow_nsnow_recent,        &! Recent new snow fSCA
  fsnow_nsnow_14days,        &! 14 days new snow fSCA
  coeff_vari,                &! Coefficient of variation of snow depth
  rhomax,                    &! Maximum snow density at preliminary peak of winter for snow covered fraction calculation (kg/m^3)
  sd_snowdepth0_dhs,         &! Parameterized standard deviation of new snow depths in a grid cell 
  sd_snowdepth0_dhs_recent   !  Parameterized standard deviation of recent new snow depths in a grid cell  
 
  ! Lower snow depth limit which is taken from swe_threshold = 2 mm 
  ! converted using the standard_density = 350 kg/m^3 to snow depth_threshold
  snowdepth_threshold = 0.005714286

  ! Calculate topo terms needed for standard deviation of snow depth 
  sd_snowdepth1 = exp(-1 / (Ld_n/xi_n)**2)
  sd_snowdepth3 = slopemu_n**(0.3193*(Ld_n**0.1034))

  ! Merge current SWEtmp with SWEtmp history from past 14 days
  SWEbuffer(1) = SWEtmp
  SWEbuffer(2:15) = swehist_n(:)
  snowdepthbuffer(1) = snowdepth_n
  snowdepthbuffer(2:15) = snowdepthhist_n(:)

  ! Update 14 days history
  swehist_n(1:14) = SWEbuffer(1:14)
  snowdepthhist_n(1:14) = snowdepthbuffer(1:14)

  ! Calculate snowdepthmin_buffer, snowdepthmax_buffer, snowdepthmin_recent 
  ! Find indices of global min and max in SWEbuffer
  iabsmax = maxloc(SWEbuffer,DIM=1)
  iabsmin = minloc(SWEbuffer,DIM=1)

  ! Find index of recent min in SWEbuffer
  ! Calculate diff vector of SWEBuffer
  do iloop = 1, 14
    diffSWEbuffer = SWEbuffer(iloop+1)-SWEbuffer(iloop)
    if (diffSWEbuffer(iloop) > 0.5) then
      EXIT
    end if
  end do
  irecentmin = minloc(SWEbuffer(1:iloop),DIM=1)

  ! Use indices to determine snow depth amounts
  snowdepthmin_buffer = snowdepthbuffer(iabsmin)
  snowdepthmax_buffer = snowdepthbuffer(iabsmax)
  snowdepthmin_recent = snowdepthbuffer(irecentmin)

  ! Compute storage of new snow on old snow in snowdepthbuffer 
  dsnowdepth = snowdepth_n - snowdepthmin_buffer
  if (dsnowdepth < 0) then
    dsnowdepth = 0
  end if

  ! Compute dswemax in SWEbuffer 
  dsnowdepthmax = snowdepthmax_buffer - snowdepthmin_buffer
  if (dsnowdepthmax < 0) then
    dsnowdepthmax = 0
  end if

  ! Don't accept dsnowdepthmax to be larger then dsnowdepth, otherwise larger fnsnow values
  if (dsnowdepthmax < dsnowdepth) then
    dsnowdepthmax = dsnowdepth
  end if

  ! Compute storage of recent new snow on old snow in SWEbuffer
  dsnowdepth_recent = snowdepth_n - snowdepthmin_recent
  if (dsnowdepth_recent < 0) then
    dsnowdepth_recent = 0
  end if

  ! Set swemax and swemin equal to zero if no snow, same with corresponding snow depth values 
  if (SWEtmp == 0) then
    swemax_n = 0
    swemin_n = 0
    snowdepthmax_n = 0
    snowdepthmin_n = 0
  end if

  ! Set swemax and swemin equal to SWEtmp if maximum, store also snowdepthmax and snowdepthmin of those time steps 
  if (SWEtmp >= swemax_n) then
    swemax_n       = SWEtmp
    swemin_n       = SWEtmp
    snowdepthmax_n = snowdepth_n
    snowdepthmin_n = snowdepth_n
  end if

  ! Set swemin equal SWEtmp if smaller than swemin, same with corresponding snow depth value 
  if (SWEtmp < swemax_n .and. SWEtmp  < swemin_n) then
    swemin_n = SWEtmp
    snowdepthmin_n = snowdepth_n
  end if

  !!! Start calculating fSCA
  ! Initial guess of fSCAs 
  fsnow_season       = 0
  fsnow_nsnow        = 0
  fsnow_nsnow_recent = 0

  !!! Seasonal fSCA, using formulas of Helbig et al.,2015 and Egli and Jonas, 2009
  ! Calculate standard deviation as in Helbig et al., 2015, 2021
  sd_snowdepth2 = snowdepthmax_n**(0.5330*(Ld_n**0.0389))
  sd_snowdepth0 = sd_snowdepth1 * sd_snowdepth2 * sd_snowdepth3
  ! Calculate standard deviation as in Egli and Jonas, 2009 for completely flat grid cells  
  if (.not.(slopemu_n > epsilon(0.0))) then
    sd_snowdepth0 = snowdepthmax_n**0.84
  end if
  ! Calculate fSCA
  if (snowdepthmax_n > 0) then
    fsnow_season = tanh(1.3 * snowdepthmin_n / sd_snowdepth0)
  end if

  !!! Calculate CV
  coeff_vari = sd_snowdepth0 / snowdepthmax_n

  !!! New snow fSCA based on dswe of last 14 days
  ! Calculate standard deviation of dhs as in Egli and Jonas, 2009
  sd_snowdepth0_dhs = dsnowdepthmax**0.84
  ! Calculate fSCA of new snow of last 14 days
  if (dsnowdepthmax > 0) then
    fsnow_nsnow = tanh(1.3 * dsnowdepth / sd_snowdepth0_dhs)
  end if

  fsnow_nsnow_14days = fsnow_nsnow

  !!! Recent new snow fSCA based on dswe_recent since last minimum
  ! Calculate standard deviation of dsnowdepth_recent as in Egli and Jonas, 2009
  sd_snowdepth0_dhs_recent = dsnowdepth_recent**0.84
  ! Calculate fSCA of recent new snow with recent dsnowdepth
  if (dsnowdepth_recent > 0) then
    fsnow_nsnow_recent = tanh(1.3 * dsnowdepth_recent / sd_snowdepth0_dhs_recent)
  end if

  !!! Take maximum between the two new snow fSCA, similar to taking the maximum of all three fSCA at the end
  fsnow_nsnow = max(fsnow_nsnow,fsnow_nsnow_recent)

  !!! If snow amounts are too low, set fSCA to zero 
  if (snowdepthmin_n < snowdepth_threshold) then
    fsnow_season = 0
  end if
  if (dsnowdepth < snowdepth_threshold) then
    fsnow_nsnow = 0
  end if

  !!! Use the largest of the two fSCA estimates
  fsnow_n = max(fsnow_season,fsnow_nsnow)

  if ( snowdepth_n < epsilon(0.0) ) then
     fsnow_n = 0
  else
    fsnow_n = min(fsnow_n, 1.)
  end if
  
end subroutine SNOWCOVERFRACTION 
