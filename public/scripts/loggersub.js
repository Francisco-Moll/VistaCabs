const formElem = document.querySelector('form#form')

// json conversion
const getFormJSON = (form) => {
    const data = new FormData(form);
    return Array.from(data.keys()).reduce((result, key) => {
        result[key] = data.get(key);
        return result;
    }, {});
};

// // handle submission
// const handler = (event) => {
//     event.preventDefault();
//     const valid = formElem.reportValidity();
//     if (valid) {
//         const result = getFormJSON(formElem);
//         console.log(result)
//     }
// }

const handler = async (event) => {
    event.preventDefault();
    const valid = formElem.reportValidity();

    if (valid) {
        const result = getFormJSON(formElem);

        try {
            const response = await fetch('/submit', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(result)
            });
            
            const data = await response.json();

            if (response.ok) {
                alert("Product logged successfully!");
                formElem.reset();
            } else {
                alert(`Error: ${data.message || 'Failed to log product.'}`);
            }
        } catch (error) {
            console.error("Request faild:", error);
            alert("Server connection failed. Please try again.");
        }
    }
};

formElem.addEventListener('submit', handler);