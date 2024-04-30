The idea is to showcase how to use python analytic instruments inside IRIS and visualise the result

### Instalation via Docker compose

1. Download the package runing
2. From root directory run ``` docker compose up -d ``` and wait till all work is done
3. After that go to ```http://localhost:53233/dsw/index.html#/ANALYTICS ```
4. You all set!

### Instalation via IPM 
The main difference with a Docker installation is that you can install KPI classes inside any other IRIS application.<br>
And get access to it without downloading whole new package

1. Run instance if InterSystems IRIS with ZPM package on it
2. In the terminal run IRIS console ``` docker compose exec -it iris iris session iris -U ANALYTICS ```
3. Then start the ZPM by input ``` zpm ```
4. After that install the package ``` install demo-pandas-analytics ```
5. After the installation is complete, open IRIS UI and procced to Management Portal->Analytics->User Portal
6. Create new dashboard and three widgets using new KPI data sources
7. When all widgets are created proceed to ```http://localhost:53233/dsw/index.html#/ANALYTICS```
8. If everything done correctly you should see three pandas based widgets
