
// 1. Get a response from the OpenAI ChatGPT API
//    - data: string or prompt to send to ChatGPT
export const getChatGPTResponse = async (data) => {
    const axios = require('axios'); // Import axios for HTTP requests
    const apiKey = process.env.CHATGPT_API_KEY; // Get API key from env

    try {
        // Make a POST request to the OpenAI API
        const response = await axios.post('https://api.openai.com/v1/chat/completions', {
            model: 'gpt-3.5-turbo', // Model to use
            messages: [{ role: 'user', content: data }], // User message
        }, {
            headers: {
                'Authorization': `Bearer ${apiKey}`, // Auth header
                'Content-Type': 'application/json',
            },
        });

        // Return the generated message content
        return response.data.choices[0].message.content; // Adjust if API response changes
    } catch (error) {
        // Log and rethrow errors
        console.error('Error fetching response from ChatGPT:', error);
        throw error; // Rethrow the error for further handling
    }
};