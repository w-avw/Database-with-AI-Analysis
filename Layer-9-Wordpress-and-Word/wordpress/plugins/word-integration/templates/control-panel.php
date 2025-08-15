<div id="controls">
  <button id="addBtn">Add Item</button>
  <button id="removeBtn">Remove Item</button>
  <button id="exportBtn">Export Word Doc</button>
</div>

<script>
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
    const res = await fetch('https://didactic-space-succotash-4j5rv77xpp5fqg9p-3001.app.github.dev/generate', {
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
</script>