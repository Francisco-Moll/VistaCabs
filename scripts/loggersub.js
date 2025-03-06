const formElem = document.querySelector('form#form')

// json conversion
const getFormJSON = (form) => {
    const data = new FormData(form);
    return Array.from(data.keys()).reduce((result, key) => {
        result[key] = data.get(key);
        return result;
    }, {});
};

// handle submission
const handler = (event) => {
    event.preventDefault();
    const valid = formElem.reportValidity();
    if (valid) {
        const result = getFormJSON(formElem);
        console.log(result)
    }
}

formElem.addEventListener("submit", handler);