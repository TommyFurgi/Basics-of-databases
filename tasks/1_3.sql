-- Napisz polecenie select, za pomocą którego uzyskasz tytuł i numer książki 
SELECT title_no,title FROM title

-- Napisz polecenie, które wybiera tytuł o numerze 10
SELECT title_no,title FROM title
WHERE title_no = 10

-- Napisz polecenie select, za pomocą którego uzyskasz numer książki (nr tyułu) i
-- autora z tablicy title dla wszystkich książek, których autorem jest Charles
-- Dickens lub Jane Austen
SELECT title_no,title FROM title
WHERE author IN ('Charles Dickens','Jane Austen')

-- Napisz polecenie, które wybiera numer tytułu i tytuł dla wszystkich książek,
-- których tytuły zawierających słowo „adventure”
SELECT title_no,title FROM title
WHERE title LIKE '%adventures%'

-- Napisz polecenie, które wybiera numer czytelnika, oraz zapłaconą karę
SELECT member_no,fine_paid FROM loanhist
WHERE fine_paid is not Null

-- Napisz polecenie, które wybiera wszystkie unikalne pary miast i stanów z tablicy adult.
SELECT DISTINCT City,state FROM adult
ORDER BY city

-- Napisz polecenie, które wybiera wszystkie tytuły z tablicy title i wyświetla je w porządku alfabetycznym.
SELECT title FROM title
ORDER BY title

-- Napisz polecenie, które:
-- – wybiera numer członka biblioteki (member_no), isbn książki (isbn) i watrość
-- naliczonej kary (fine_assessed) z tablicy loanhist dla wszystkich wypożyczeń
-- dla których naliczono karę (wartość nie NULL w kolumnie fine_assessed)
-- – stwórz kolumnę wyliczeniową zawierającą podwojoną wartość kolumny
-- fine_assessed
-- – stwórz alias ‘double fine’ dla tej kolumny 
SELECT member_no,isbn,fine_assessed,2*fine_assessed AS double_fine
FROM loanhist
WHERE fine_assessed IS NOT Null


-- Napisz polecenie, które
-- – generuje pojedynczą kolumnę, która zawiera kolumny: firstname (imię
-- członka biblioteki), middleinitial (inicjał drugiego imienia) i lastname
-- (nazwisko) z tablicy member dla wszystkich członków biblioteki, którzy
-- nazywają się Anderson
-- – nazwij tak powstałą kolumnę email_name (użyj aliasu email_name dla
-- kolumny)
-- – zmodyfikuj polecenie, tak by zwróciło „listę proponowanych loginów e-mail”
-- utworzonych przez połączenie imienia członka biblioteki, z inicjałem
-- drugiego imienia i pierwszymi dwoma literami nazwiska (wszystko małymi
-- małymi literami).
-- – Wykorzystaj funkcję SUBSTRING do uzyskania części kolumny
-- znakowej oraz LOWER do zwrócenia wyniku małymi literami.
-- Wykorzystaj operator (+) do połączenia stringów.
SELECT LOWER(REPLACE(firstname, ' ', '')+middleinitial+SUBSTRING(lastname,1,2)) AS email_name
FROM member
WHERE lastname = 'Anderson'

-- Napisz polecenie, które wybiera title i title_no z tablicy title.
-- § Wynikiem powinna być pojedyncza kolumna o formacie jak w przykładzie
-- poniżej:
-- The title is: Poems, title number 7
-- § Czyli zapytanie powinno zwracać pojedynczą kolumnę w oparciu o
-- wyrażenie, które łączy 4 elementy:
-- stała znakowa ‘The title is:’
-- wartość kolumny title
-- stała znakowa ‘title number’
-- wartość kolumny title_no
SELECT CONCAT('The title is: ', title, ', title number ', title_no) AS book_info
FROM title