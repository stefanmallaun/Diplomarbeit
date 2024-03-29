import DataForContries as d
import mysql.connector
import json

# ALL KEYS IN DATAFORDATABASE
#   ['name', 'tld', 'cca2', 'ccn3', 'cca3', 'independent', 'status', 'unMember', 'currencies', 'idd', 'capital', 'altSpellings', 'region', 'subregion', 
#   'languages', 'translations', 'latlng', 'landlocked', 'area', 'demonyms', 'flag', 'maps', 'population', 'car', 'timezones', 'continents', 'flags', 
#   'coatOfArms', 'startOfWeek', 'capitalInfo', 'postalCode', 'cioc', 'borders', 'fifa', 'gini']

# KEYS WE USE
#   ['name', 'cca2', 'cca3', 'independent', 'status', 'unMember', 'currencies', 'capital',
#   'languages', 'landlocked', 'area', 'population', 'car', 'timezones', 'continents', 'borders']

# FIELDS IN COUNTRY
#   name (string), official_name (string), cca2 (string), cca3 (string), independent (boolean), status (string), un_member (boolean), currencies (list), 
#   capital (list), languages (list), landlocked (boolean), area (float), population (int), timezones (list), continent (string)
# LISTS FOR OTHER TABLES
#   borders (list), alt_spellings (list)

# CONNECT DB (to establish the connection)
def connect_db():
    # the database is specified with password and host as well as user
    mydb = mysql.connector.connect(host="localhost", user="root", password="david2003", database="diplomarbeit")
    #mydb = mysql.connector.connect(host="localhost", user="root", password="dipl", database="diplomarbeit")
    # the cursor and the database are returned
    return mydb.cursor(), mydb

# GLOBAL DICTIONARIES (these are global because they are processed in several methods)
# all alternative spellings are stored here and are entered into the alternative_spellings_to_country table
alternative_spellings = {'United Arab Emirates': ["UAE", "Arab Emirates"], 'Antigua and Barbuda': ["Antigua", "Barbuda"], 
                         'Bosnia and Herzegovina': ["Bosnia", "Herzegovina"], 'Central African Republic': ["CAR", "Central Africa"], 'DR Congo': ["Congo", "DRC"], 
                         'Republic of the Congo': ["Congo", "ROC"], 'Dominican Republic': ["Dominican"], 'United Kingdom': ["UK", "Great Britain"], 
                         'Guinea-Bissau': ["Guinea Bissau"], 'Saint Kitts and Nevis': ["Saint Kitts", "Saint Nevis", "Kitts and Nevis"], 
                         'North Macedonia': ["Macedonia"], 'Papua New Guinea': ["Papua", "New Guinea"], 'Sao Tome and Principe': ["Sao Tome", "Tome and Principe"], 
                         'Timor-Leste': ["Timor Leste", "Timor"],'Trinidad and Tobago': ["Trinidad", "Tobago"], 'United States': ["USA", "United States of America"], 
                         'Vatican City': ["Vatican"], 'Saint Vincent and the Grenadines': ["Saint Vincent", "Grenadines"]}
# all borders are saved here to enter them into the borders_to_county table
borders_dict = {}

# ARRANGE COUNTRY INSERT STRING (breaks down the passed data string and arranges the fields we need in the correct order)
def arrange_country_insert_string(data):
    # NAME, OFFICIAL_NAME
    allnames = data['name']
    name = allnames['common'].encode('utf-8')
    name = name.decode('utf-8')
    print("\nname: " + name)
    official_name = allnames['official'].encode('utf-8')
    official_name = official_name.decode('utf-8')
    #print("official_name: " + official_name)
    
    # CCA2, CCA3
    cca2 = data['cca2']
    cca3 = data['cca3']
    #print("cca2: " + cca2 + " cca3: " + cca3)
    
    # INDEPENDENT
    if 'independent' in data:
        independent = data['independent']
    else:
        independent = False
    #print("independent: " + str(independent))
    
    # STATUS, UN_MEMBER
    status = data['status']
    un_member = data['unMember']
    #print("status: " + status + " un_member: " + str(un_member))
    
    # CURRENCIES
    if 'currencies' in data:
        currencies = data['currencies']
    else:
        currencies = {}
    #print("currensies: " + str(currencies))
    
    # CAPITAL
    if 'capital' in data:
        allcapitals = data['capital']
        for i in allcapitals:
            i = i.encode('utf-8')
            i = i.decode('utf-8')
        capital = allcapitals
    else:
        capital = ""
    #print("capital: " + str(capital))
    
    # LANGUAGES
    languages = []
    if 'languages' in data:
        alllanguages = data['languages']
        for i in alllanguages:
            language = alllanguages[i].encode('utf-8')
            languages.append(language.decode('utf-8'))
    #print("languages: " + str(languages))
    
    # LANDLOCKED
    landlocked = data['landlocked']
    #print("landlocked: " + str(landlocked))
    
    # AREA
    area = data['area']
    #print("area: " + str(area))
    
    # POPULATION
    population = data['population']
    #print("population: " + str(population))
    
    # TIMEZONES
    timezones = data['timezones']
    #print("timezones: " + str(timezones))
    
    # CONTINENT
    # the case of two continents isnt relevant anymore, due to the fact there were 3 conties which i manualy changed to one continent (Turkey, Russia, Azerbaijan)
    continents = data['continents']
    if len(continents) > 1:
        print("Error: " + name + " has more than one continent.")
    else:
        continent = continents[0]
    #print("continent: " + str(continent))
    
    # BORDERS
    if 'borders' in data:
        borders_dict.update({cca2: data['borders']})

    # ALT_SPELLINGS
    for altspell in alternative_spellings:
        if altspell == name:
            alt_spellings = alternative_spellings[name]
            for spelling in alt_spellings:
                insertstring = '"' + cca2 + '", "' + spelling + '"'
                insert_into_alternative_spellings_to_country(insertstring)
        
    # ARRANGE INSERT STRING
    #name (string), official_name (string), cca2 (string), cca3 (string), independent (boolean), status (string), un_member (boolean), currencies (list), 
    #capital (list), languages (list), landlocked (boolean), area (float), population (int), timezones (list), continents (list)
    returnvalue = '"' + name + '","' + official_name + '","' + cca2 + '","' + cca3 + '","' + str(int(independent)) + '","' + status + '","' + str(int(un_member)) 
    returnvalue = returnvalue + '","' + str(currencies) + '","' + str(capital) + '","' + str(languages) + '","' + str(int(landlocked)) + '","' + str(area)
    returnvalue = returnvalue + '","' + str(population) + '","' + str(timezones) + '","' + str(continent) + '"'
    return returnvalue

def list_to_json(values):
    values_json = json.dumps(values)
    return values_json

def arrange_border_insert_string():
    for country in borders_dict:
        #print(borders_dict[country])
        border_countries = replace_cca3_with_cca2(borders_dict[country])
        allready_saved = select_border(country)
        for border in border_countries:
            saved = False
            for i in allready_saved:
                if i == border:
                    saved = True
            if saved == False:
                insert_into_border_to_country('"' + country + '", "' + border + '"')

def replace_cca3_with_cca2(border_countries):
    mycursor, mydb = connect_db()
    returnvalue = []
    for cca3 in border_countries:
        mycursor.execute("select cca2 from country where cca3 = \'" + cca3 + "\'")
        result = mycursor.fetchall()
        cca2 = result[0]
        returnvalue.append(cca2[0])
    mydb.close()
    return returnvalue

def select_border(cca2):
    mycursor, mydb = connect_db()
    mycursor.execute("select cca2 from border_to_country where border = \'" + cca2 + "\'")
    result = mycursor.fetchall()
    returnvalue = []
    for border in result:
        returnvalue.append(border[0])
    mydb.close()
    return returnvalue

def insert_into_alternative_spellings_to_country(insertstring):
    mycursor, mydb = connect_db()
    insert_query = "INSERT INTO alternative_spellings_to_country VALUES (" + str(insertstring) + ")"
    try:
        mycursor.execute(insert_query)
        mydb.commit()
        print("alternative spelling inserted successfully.")
    except mysql.connector.Error as error:
        mydb.rollback()
        print(f"Error inserting record: {error}")
    mydb.close()

def insert_into_country(insertstring):
    mycursor, mydb = connect_db()
    insert_query = "INSERT INTO country VALUES (" + str(insertstring) + ")"
    try:
        mycursor.execute(insert_query)
        mydb.commit()
        print("country inserted successfully.")
    except mysql.connector.Error as error:
        mydb.rollback()
        print(f"Error inserting record: {error}")
    mydb.close()

def insert_into_border_to_country(insertstring):
    mycursor, mydb = connect_db()
    insert_query = "INSERT INTO border_to_country VALUES (" + str(insertstring) + ")"
    try:
        mycursor.execute(insert_query)
        mydb.commit()
        print("border inserted successfully.")
    except mysql.connector.Error as error:
        mydb.rollback()
        print(f"Error inserting record: {error}")
    mydb.close()

def insert_country_and_alternative_spelling_data(alldata):
    tempcount = 0
    for i in alldata:
        insertstring = arrange_country_insert_string(i)
        tempcount = tempcount + 1
        #print("\n" + insertstring)
        insert_into_country(insertstring)
        print(tempcount)

if __name__ == '__main__':
    insert_country_and_alternative_spelling_data(d.data)
    arrange_border_insert_string()
    