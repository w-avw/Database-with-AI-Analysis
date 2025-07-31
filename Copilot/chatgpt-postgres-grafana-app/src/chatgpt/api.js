export const getChatGPTResponse = async (data) => {
    const axios = require('axios');
    const apiKey = process.env.CHATGPT_API_KEY; // Ensure you have your API key in the .env file

    try {
        const response = await axios.post('https://api.openai.com/v1/chat/completions', {
            model: 'gpt-3.5-turbo', // or the model you want to use
            messages: [{ role: 'user', content: data }],
        }, {
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json',
            },
        });

        return response.data.choices[0].message.content; // Adjust based on the API response structure
    } catch (error) {
        console.error('Error fetching response from ChatGPT:', error);
        throw error; // Rethrow the error for further handling
    }
};