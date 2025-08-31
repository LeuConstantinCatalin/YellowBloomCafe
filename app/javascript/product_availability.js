import { createConsumer } from "@rails/actioncable";

const consumer = createConsumer();

function sortList(ul) {
  const items = Array.from(ul.querySelectorAll('li'));
  items.sort((a, b) => {
    const aAvail = (a.dataset.available === 'true') ? 0 : 1;
    const bAvail = (b.dataset.available === 'true') ? 0 : 1;
    if (aAvail !== bAvail) return aAvail - bAvail;
    const an = (a.dataset.name || '').localeCompare(b.dataset.name || '');
    return an;
  });
  items.forEach(li => ul.appendChild(li));
}

function handleAvailabilityUpdate(data) {
  const { product_id, available } = data;
  const li = document.getElementById(`product-${product_id}`);
  if (!li) return;


  li.dataset.available = available ? 'true' : 'false';


  let label = li.querySelector('.product-status.unavailable');
  if (available) {
    if (label) label.remove();
  } else {
    if (!label) {
      label = document.createElement('span');
      label.className = 'product-status unavailable';
      label.textContent = 'indisponibil';
      const priceContainer = li.querySelector('.product-info > div');
      if (priceContainer) priceContainer.appendChild(label);
    }
  }


  const ul = li.closest('ul');
  if (ul) sortList(ul);
}


document.addEventListener('DOMContentLoaded', () => {
  consumer.subscriptions.create('ProductAvailabilityChannel', {
    received: handleAvailabilityUpdate
  });
});

document.addEventListener('turbo:load', () => {
  consumer.subscriptions.create('ProductAvailabilityChannel', {
    received: handleAvailabilityUpdate
  });
});

