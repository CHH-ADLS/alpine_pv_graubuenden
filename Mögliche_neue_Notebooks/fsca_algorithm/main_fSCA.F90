!-----------------------------------------------------------------------
! Main file for seasonal fSCA algorithm (Helbig et al., 2021)
! - here for one grid cell; has to be adapted for a spatial NxM grid
!-----------------------------------------------------------------------

program fSCA

implicit none

integer :: &
  i,                   &! Point counters
  imin,                &! Location of min swe
  imax                  ! Location of max swe
  
real*8:: &
  slopemu,             &! Squared slope related parameter
  xi,                  &! Terrain correlation length (m)
  Ld,                  &! Model domain size (e.g. 1000m grid cell size)
  stddem                ! Standard deviation of subgrid DEM (m) 

real*8 :: &
  fsnow,               &! Snow cover fraction
  SWEtmp,              &! Temporary snow water equivalent for snow covered fraction calculation (kg/m^2)
  swehist(14),         &! History of swe during last 14 days (kg/m^2)
  swemin,              &! Minimum swe during the season (m)
  swemax,              &! Maximum swe during the season (m)
  snowdepth,           &! Snow depth (m)
  snowdepthhist(14),   &! History of snow depth during last 14 days (m)
  snowdepthmin,        &! Minimum Snow depth at time step of swemin (m)
  snowdepthmax          ! Maximum Snow depth at time stemp of swemax(m)

! Initialize history with zero
swehist(:) = 0
snowdepthhist(:) = 0

! Open input and output files
Open(1,file='HS_SWE.txt')
Open(2,file='fSCA.txt')

! Terrain parameters as in Helbig et al., 2015, 2021 - set or read in
Ld = 1000
slopemu = 0.4485
stddem = 117.85
xi = 2*stddem/slopemu

! Loop over timesteps
do i = 1, 365

   read(1,*) snowdepth,SWEtmp

   ! Call Compute Fractional Snow-Covered Area 
   call SNOWCOVERFRACTION(fsnow,snowdepth,SWEtmp,swehist(:),swemin,swemax, &
                         snowdepthhist(:),snowdepthmin,snowdepthmax, &
                         slopemu,xi,Ld)
   
   ! Write out fSCA
   write(2,'(F6.4)') fsnow
 end do

end
