clear all
close all
%%
url_wav_w = "https://thredds.met.no/thredds/dodsC/fou-hi/mywavewam800mhf/mywavewam800_midtnorge.an.2020021918.nc";
url_curr = "https://thredds.met.no/thredds/dodsC/fou-hi/norkyst800m-1h/NorKyst-800m_ZDEPTHS_his.an.2020022200.nc";



%%
latitude_map_wav = ncread(url_wav_w,'latitude');
longitude_map_wav = ncread(url_wav_w,'longitude');
%%
wind_speed_wav = ncread(url_wav_w,'ff');

%%
wind_dir_wav = ncread(url_wav_w,'dd');

%%
info = ncinfo(url_curr);

curr_lat = ncread(url_curr,'lat');
curr_long = ncread(url_curr,'lon');
%%
curr_east = ncread(url_curr,'u_eastward');
%%
curr_north = ncread(url_curr,'v_northward');


