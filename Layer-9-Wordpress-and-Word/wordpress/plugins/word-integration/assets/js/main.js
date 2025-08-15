let items = [];

document.getElementById('addBtn').onclick = () => {
    const newItem = prompt('Enter item:');
    if(newItem) items.push(newItem);
};

document.getElementById('removeBtn').onclick = () => {
    const itemToRemove = prompt('Enter item to remove:');
    items = items.filter(i => i !== itemToRemove);
};

document.getElementById('exportBtn').onclick = async () => {
    const res = await fetch('https://<your-codespace-url>/generate', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ items })
    });
    const blob = await res.blob();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'final.docx';
    document.body.appendChild(a);
    a.click();
    a.remove();
};