export const insertData = async (client, data) => {
    const query = 'INSERT INTO your_table_name(column1, column2) VALUES($1, $2) RETURNING *';
    const values = [data.column1, data.column2];
    const res = await client.query(query, values);
    return res.rows[0];
};

export const fetchData = async (client) => {
    const query = 'SELECT * FROM your_table_name';
    const res = await client.query(query);
    return res.rows;
};

export const updateData = async (client, id, newData) => {
    const query = 'UPDATE your_table_name SET column1 = $1, column2 = $2 WHERE id = $3 RETURNING *';
    const values = [newData.column1, newData.column2, id];
    const res = await client.query(query, values);
    return res.rows[0];
};