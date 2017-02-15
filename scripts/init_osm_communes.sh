# import des limites administratives issues d'OSM

cd ../data/osm/

# détail communes (2014)
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-plus-20140630-100m-shp.zip
unzip -u -o communes-plus-20140630-100m-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-plus-20140630-100m-shp/communes-plus-20140630-100m.shp -overwrite -nlt GEOMETRY -nln osm_communes -skipfailures
psql -c "
create index osm_communes_index on osm_communes using gist(wkb_geometry);
create index osm_communes_insee on osm_communes (insee);
"

# limites communes au 1/1/2015
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-20150101-5m-shp.zip
unzip -u -o communes-20150101-5m-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-plus-20150101-5m-shp/communes-plus-20150101-5m.shp -overwrite -nlt GEOMETRY -nln osm_communes_2015 -skipfailures
psql -c "
alter table osm_communes_2015 drop ogc_fid;
create index osm_communes_2015_index on osm_communes_2015 using gist(wkb_geometry);
create index osm_communes_2015_insee on osm_communes_2015 (insee);
"

# limites communes au 1/1/2016 pour les fusions
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-20160119-shp.zip
unzip -u -o communes-20160119-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-20160119.shp -overwrite -nlt GEOMETRY -nln osm_communes_2016 -skipfailures
psql -c "
alter table osm_communes_2016 drop ogc_fid;
create index osm_communes_2016_insee on osm_communes_2016 (insee);
"

# limites communes au 1/1/2017 pour les fusions
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-20170111-shp.zip
unzip -u -o communes-20170111-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-20170111-shp/*.shp -overwrite -nlt GEOMETRY -nln osm_communes_2017 -skipfailures
psql -c "
alter table osm_communes_2017 drop ogc_fid;
create index osm_communes_2017_insee on osm_communes_2017 (insee);
"

# liste des régions 2016 (noms finaux)
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/regions-20170102-shp.zip
unzip regions-20170102-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: regions-20170102.shp -overwrite -nlt GEOMETRY -nln osm_regions_2016 -skipfailures
rm regions-20170102*
psql -c "
create index osm_regions_2016_index on osm_regions_2016 using gist(wkb_geometry);
create index osm_regions_2016_insee on osm_regions_2016 (insee);

create or replace view dep_reg_2016 as select d.*, nom_reg, d2.tncc as dep_tncc, r2.nom as nom_reg2016 from cog_dep d join cog_reg r on (r.reg=d.reg) join insee_depts_2016 d2 on (d2.dep=d.dep) left join osm_regions_2016 r2 on (r2.insee=d2.region);
"
