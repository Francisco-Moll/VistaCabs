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
            const response = await fetch('http://localhost:3000/submit', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(result)
            });
            
            const data = await response.json();
            alert(data.message);
        } catch (error) {

        }
    }
};

formElem.addEventListener("submit", handler);