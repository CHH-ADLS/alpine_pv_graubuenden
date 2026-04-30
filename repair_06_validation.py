from pathlib import Path
import json

p = Path(r'c:\Users\halod\Desktop\PA1\PA1Git\projekt_final\notebooks\06_validation.ipynb')
nb = json.loads(p.read_text(encoding='utf-8'))
for i, cell in enumerate(nb['cells']):
    if cell['cell_type'] != 'code':
        continue
    if any('Hit Rate pro Status' in line for line in cell['source']):
        cell['source'] = [
            "positive_statuses = ['connected to grid', 'under construction', 'in planning']\n",
            "positive = gdf_plants[gdf_plants['status'].isin(positive_statuses)].copy()\n",
            "positive['hit'] = positive['suit_value'] > 0\n",
            "hit_count = int(positive['hit'].sum())\n",
            "hit_rate = hit_count / len(positive) * 100\n",
            "print(f'Hit Rate positiv: {hit_count}/{len(positive)} ({hit_rate:.1f} %)')\n",
            "\n",
            "status_stats = []\n",
            "for status in STATUS_ORDER:\n",
            "    group = gdf_plants[gdf_plants['status'] == status]\n",
            "    hits = int((group['suit_value'] > 0).sum())\n",
            "    status_stats.append({'Status': status, 'Total': len(group), 'Treffer': hits, 'HitRate': hits / len(group) * 100 if len(group) else np.nan})\n",
            "df_hit = pd.DataFrame(status_stats)\n",
            "print('\\nHit Rate pro Status:')\n",
            "print(df_hit.to_string(index=False))\n",
            "\n",
            "missing = []\n",
            "for _, r in positive.loc[~positive['hit']].iterrows():\n",
            "    if r['in_constraint'] == 'OOB':\n",
            "        reason = 'OOB'\n",
            "    elif r['in_constraint'] != '✓':\n",
            "        reason = 'außerhalb Constraint-Maske'\n",
            "    else:\n",
            "        reason = 'suit_value <= 0'\n",
            "    missing.append(f'{r.name} ({reason})')\n",
            "if missing:\n",
            "    print(f'Fehlende positive Standorte: {len(missing)}')\n",
            "    for item in missing:\n",
            "        print(' -', item)\n",
            "\n",
            "fig, ax = plt.subplots(figsize=(10, 5))\n",
            "bars = ax.bar(df_hit['Status'], df_hit['HitRate'], color=[STATUS_COLORS[s] for s in df_hit['Status']])\n",
            "for bar, count, total in zip(bars, df_hit['Treffer'], df_hit['Total']):\n",
            "    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 2, f'{count}/{total}', ha='center', va='bottom', fontsize=8)\n",
            "ax.set_ylim(0, 110)\n",
            "ax.axhline(100, color='gray', ls='--', linewidth=1, alpha=0.7)\n",
            "ax.axhline(50, color='gray', ls=':', linewidth=1, alpha=0.7)\n",
            "ax.set_ylabel('Hit Rate (%)')\n",
            "ax.set_title('Hit Rate der realen und geplanten Standorte')\n",
            "ax.set_xticklabels([s.replace('_', ' ').title() for s in df_hit['Status']], rotation=30, ha='right')\n",
            "plt.tight_layout()\n",
            "fig.savefig(OUT_F / 'validation_hitrate.png', dpi=150, bbox_inches='tight')\n",
            "plt.show()\n",
        ]
        break
p.write_text(json.dumps(nb, indent=1, ensure_ascii=False), encoding='utf-8')
print('repair done')
