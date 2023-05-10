function fetchFile(fileUrl) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('GET', fileUrl);
    xhr.onload = function() {
      if (xhr.status === 200) {
        resolve(xhr.responseText);
      } else {
        reject(new Error(`Falha ao carregar o arquivo: ${fileUrl}`));
      }
    };
    xhr.onerror = function() {
      reject(new Error(`Erro de rede ao carregar o arquivo: ${fileUrl}`));
    };
    xhr.send();
  });
}

const python_file = 'carros_americanos.py'
const csv_file = 'carros_americanos.csv'

async function loadPython() {
  try {
    const python_code = await fetchFile(python_file);
    const csv_code = {csv_string: await fetchFile(csv_file)};
    await asyncRun(python_code, csv_code);
  } catch (e) {
    console.log(
      `Error in pyodideWorker at ${e.filename}, Line: ${e.lineno}, ${e.message}`,
    );
  }
}


async function getMappedCodes() {
    try {
        const { results, error } = await asyncRun("get_mapping_json()", {})
        if (results) {
            console.log(results)
            return results;
        } else if (error) {
            console.log("pyodideWorker error: ", error);
        }
    } catch (e) {
        console.log(`Error in pyodideWorker at ${e.filename}, Line: ${e.lineno}, ${e.message}`,);
    }
}

async function predictPrice(values) {
    try {
        console.log(values)
        const context = {input_values: values.map((value) => parseInt(value))}
        const { results, error } = await asyncRun("predict_price()", context)
        if (results) {
            console.log(results)
            return results;
        } else if (error) {
            console.log("pyodideWorker error: ", error);
        }
    } catch (e) {
        console.log(`Error in pyodideWorker at ${e.filename}, Line: ${e.lineno}, ${e.message}`,);
    }
}