import pandas as pd
import numpy as np
import json
from io import StringIO
import js

"""
CarName => concatenar (Make, Model, Trim)
fueltype => Fuel type
aspiration => (sem equivalente) Transmission
doornumber => Doors
carbody => Body type
drivewheel => (sem equivalente) Torque (rpm)
enginelocation => (sem equivalente) Total seating
enginetype => Engine type
cylindernumber => Cylinders
fuelsystem => (sem equivalente) Fuel tank capacity (gal)
enginesize => Engine size (l) 
carwidth => Width (in)
carheight => Height (in)
carlength => Length (in)
curbweight => Curb weight (lbs)
horsepower => Horsepower (HP)
wheelbase => Wheelbase (in)
boreratio => (sem equivalente) Ground clearance (in)

price =  pode ser o Base Invoice ou Base MSRP
"""

df_cars = pd.read_csv(StringIO(js.csv_string), sep="," , encoding="UTF8")

lista_mappings = {}

dados_codificaveis = ['Make', 'Model', 'Fuel type', 'Transmission', 'Body type', 'Engine type', 'Cylinders']

for dados in dados_codificaveis:
    mapping = {k: v for k, v in zip(df_cars[dados], df_cars[dados].astype('category').cat.codes)}
    lista_mappings[dados] = mapping
    df_cars[dados] = df_cars[dados].replace(mapping)

def get_mapping_json():
    return json.dumps(lista_mappings, indent=4)

df_cars = df_cars.assign(Width=df_cars['Width (in)'] * 2.54,
                         Height=df_cars['Height (in)'] * 2.54,
                         Length=df_cars['Length (in)'] * 2.54,
                         Wheelbase=df_cars['Wheelbase (in)'] * 2.54,
                         Ground_clearance=df_cars['Ground clearance (in)'] * 2.54)

df_cars['Curb weight'] = df_cars['Curb weight (lbs)'].apply(lambda x: x * 0.453592) #converte libras para quilograma
df_cars['Fuel tank capacity'] = df_cars['Fuel tank capacity (gal)'].apply(lambda x: x * 3.78541) #converte galões para litros

df_cars['Base Invoice'] = df_cars['Base Invoice'].str.replace('$', '').str.replace(',', '.').astype(float)
df_cars['Base MSRP'] = df_cars['Base MSRP'].str.replace('$', '').str.replace(',', '').astype(float)
df_cars.fillna(1, inplace=True)

features_independentes = [
    'Transmission',
    'Doors',
    'Body type',
    'Total seating',
    'Cylinders',
    'Ground_clearance',
    'Curb weight',
    'Horsepower (HP)',
]

X = df_cars[features_independentes]
y = df_cars['Base MSRP']



from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn import metrics

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=101)
lm = LinearRegression()
lm.fit(X_train, y_train)
predictions = lm.predict(X_test)

def get_errors_metrics():
    return json.dumps({
        'MAE': metrics.mean_absolute_error(y_test, predictions),
        'MSE': metrics.mean_squared_error(y_test, predictions),
        'RMSE': np.sqrt(metrics.mean_squared_error(y_test, predictions))
    }, ident=4)

coeff_df = pd.DataFrame(lm.coef_, X.columns, columns=['Coefficient'])

def predict_price():
    valores = list(js.input_values)
    result = lm.predict(np.array(valores).reshape(1, -1))
    return result[0]

def get_coefficient():
    return json.dumps(coeff_df.sort_values(by='Coefficient', ascending=False).to_dict(), ident=4)
