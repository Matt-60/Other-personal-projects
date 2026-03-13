import streamlit as st
import pandas as pd
import plotly.express as px

st.title('Wyniki ankiety')

# Wczytanie danych
df = pd.read_csv("welcome_survey_cleaned.csv", sep=";")

# Mapowanie wartości kolumny gender
gender_map = {0: 'Mężczyzna', 1: 'Kobieta'}
df['gender'] = df['gender'].map(gender_map)

# Liczba ankietowanych
st.header('Liczba wszystkich ankieterów')
c0, c1, c2 = st.columns(3)

with c0:
    st.metric('Liczba ankietowanych', len(df))
with c1:
    st.metric('Liczba mężczyzn', len(df[df['gender'] == 'Mężczyzna']))
with c2:
    st.metric('Liczba kobiet', len(df[df['gender'] == 'Kobieta']))

# Sekcja sidebar dla filtrów
st.sidebar.header("Opcje filtrowania")

select_age = ['Wszystkie przedziały wiekowe'] + list(df['age'].unique())
selected_age = st.sidebar.selectbox('Wybierz przedział wiekowy', select_age)

select_gender = ['Wszystkie płcie', 'Mężczyzna', 'Kobieta']
selected_gender = st.sidebar.selectbox('Wybierz płeć', select_gender)

education = st.sidebar.multiselect('Wybierz wykształcenie', sorted(df['edu_level'].dropna().unique()))

select_industry = ['Wszystkie branże'] + list(df['industry'].unique())
selected_industry = st.sidebar.selectbox('Wybierz branżę', select_industry)

experience = st.sidebar.multiselect('Doświadczenie zawodowe', sorted(df['years_of_experience'].dropna().unique()))

# Mapowanie wartości kolumny sweet_or_salty
taste_map = {"sweet": "Słodkie", "salty": "Słone"}
df['sweet_or_salty'] = df['sweet_or_salty'].map(taste_map)

# Wyświetlanie filtrowanych danych
st.header('Przykładowe dane')
st.dataframe(df.head(), hide_index=True)

# Przyciski filtrowania
if st.sidebar.button("Wyświetl"):
    # Filtrowanie danych na podstawie wyborów użytkownika
    if selected_age != 'Wszystkie przedziały wiekowe':
        df = df[df['age'] == selected_age]
    if selected_industry != 'Wszystkie branże':
        df = df[df['industry'] == selected_industry]
    if selected_gender != 'Wszystkie płcie':
        df = df[df['gender'] == selected_gender] 
    if experience:
        df = df[df['years_of_experience'].isin(experience)]
    if education:
        df = df[df['edu_level'].isin(education)]

    # Liczba ankietowanych po filtracji
    st.header('Liczba ankieterów po filtracji')
    c0, c1, c2 = st.columns(3)
    with c0:
        st.metric('Liczba ankietowanych', len(df))
    with c1:
        st.metric('Liczba mężczyzn', len(df[df['gender'] == 'Mężczyzna']))
    with c2:
        st.metric('Liczba kobiet', len(df[df['gender'] == 'Kobieta']))

# Ulubione zwierzę
st.header('Ulubione zwierzęta')

count_animal = df['fav_animals'].value_counts()

fig_animals = px.bar(
    x=count_animal.index, 
    y=count_animal.values, 
    title='Jakie zwierzę preferujesz?',
    labels={'x': 'Kategoria zwierząt', 'y': 'Ilość'}
)

st.plotly_chart(fig_animals)

# Ulubione miejsce
st.header('Ulubione miejsce')

favourite_place = df['fav_place'].value_counts()

fig_favourite_place = px.pie(
    values=favourite_place.values,
    names=favourite_place.index, 
    title='Gdzie lubisz wypoczywać?'
)

st.plotly_chart(fig_favourite_place)

# Preferencje dotyczące nauki
st.header('Preferencje dotyczące nauki')

learn_preferences = {
'learning_pref_books': 'Książki',
'learning_pref_chatgpt': 'ChatGPT',
'learning_pref_offline_courses': 'Kursy stacjonarne',
'learning_pref_online_courses': 'Kursy online',
'learning_pref_personal_projects': 'Projekty własne',
'learning_pref_teaching': 'Nauczanie',
'learning_pref_teamwork': 'Praca zespołowa',
'learning_pref_workshops': 'Warsztaty'
}

learn_data = df[learn_preferences.keys()].sum().rename(learn_preferences).sort_values(ascending=False)

fig_learn = px.bar(
    x=learn_data.index, 
    y=learn_data.values, 
    title='W jaki sposób lubisz się uczyć?',
    labels={'x': 'Preferencje uczenia się', 'y': 'Ilość'}
)

st.plotly_chart(fig_learn)

# Motywacje
st.header('Motywacje')

motivation = {
'motivation_career': 'Kariera',
'motivation_challenges': 'Wyzwania',
'motivation_creativity_and_innovation': 'Kreatywność i innowacje',
'motivation_money': 'Pieniądze / Praca',
'motivation_personal_growth': 'Rozwój osobisty',
'motivation_remote': 'Praca zdalna'
}

motivation_data = df[motivation.keys()].sum().rename(motivation).sort_values(ascending=False)

fig_motivation = px.bar(
    x=motivation_data.index, 
    y=motivation_data.values, 
    title='Co nas motywuje?',
    labels={'x': 'Rodzaj motywacji', 'y': 'Ilość'}
)

st.plotly_chart(fig_motivation)

# Hobby
st.header('Hobby')

hobby = {
    'hobby_art': 'Sztuka',
    'hobby_books': 'Książki',
    'hobby_movies': 'Filmy',
    'hobby_other': 'Inne',
    'hobby_sport': 'Sport',
    'hobby_video_games': 'Gry'
}

hobby_data = df[hobby.keys()].sum().rename(hobby).sort_values(ascending=False)

fig_hobby = px.bar(
    x=hobby_data.index,
    y=hobby_data.values,
    title='Nasze hobby',
    labels={'x': 'Hobby', 'y': 'Ilość'}
)

st.plotly_chart(fig_hobby)

st.header("Ulubione jedzenie")
sweeet_salty = df['sweet_or_salty'].value_counts()

fig_favourite_place = px.pie(
    values=sweeet_salty.values,
    names=sweeet_salty.index, 
    title='Słodkie vs słone?'
)

st.plotly_chart(fig_favourite_place)