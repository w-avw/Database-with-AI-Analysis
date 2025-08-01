
// 1. Insert a new row into the table
//    - client: pg client instance
//    - data: object with column1 and column2
export const insertData = async (client, data) => {
    const query = 'INSERT INTO your_table_name(column1, column2) VALUES($1, $2) RETURNING *'; // SQL insert
    const values = [data.column1, data.column2]; // Values to insert
    const res = await client.query(query, values); // Execute query
    return res.rows[0]; // Return inserted row
};

// 2. Fetch all rows from the table
//    - client: pg client instance
export const fetchData = async (client) => {
    const query = 'SELECT * FROM your_table_name'; // SQL select
    const res = await client.query(query); // Execute query
    return res.rows; // Return all rows
};

// 3. Update a row in the table by id
//    - client: pg client instance
//    - id: row id to update
//    - newData: object with new column1 and column2 values
export const updateData = async (client, id, newData) => {
    const query = 'UPDATE your_table_name SET column1 = $1, column2 = $2 WHERE id = $3 RETURNING *'; // SQL update
    const values = [newData.column1, newData.column2, id]; // New values and id
    const res = await client.query(query, values); // Execute query
    return res.rows[0]; // Return updated row
};