# DEZHURKA
To run the game:
1) Create postgresql database
2) Create .env file with such strcture:
```
USER=<UserName>
PASSWORD=<DbPassword>
DB_NAME=<DbName>
```
3) Run all sql scripts in such order: types, tables, triggers, views, functions, game_logic, data
4) Run this in the project root:
```
pip install -r requirements.txt
streamlit run app/main.py
```
  
