function configureGrafanaDatasource() {
    const datasource = {
        type: 'postgres',
        name: 'PostgreSQL Datasource',
        url: process.env.GRAFANA_DB_URL,
        access: 'proxy',
        jsonData: {
            sslmode: 'disable',
        },
        secureJsonData: {
            password: process.env.GRAFANA_DB_PASSWORD,
        },
    };

    return datasource;
}

export default configureGrafanaDatasource;