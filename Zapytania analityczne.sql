--1. ROLLUP

SELECT NVL(TO_CHAR(ZLECENIE.TYP_ZLECENIA_ID_TYPU),' ') AS "TYP ZLECENIA",  NVL(TO_CHAR(ZLECENIE.CZAS_TRWANIA),' ') AS "CZAS TRWANIA", TO_CHAR(ROUND(AVG(ZLECENIE.CENA_USLUGI),2))||'Z�' AS "CENA USLUGI", 
TO_CHAR(ROUND(AVG(ZLECENIE.KOSZT_MATERIALOW),2))||'Z�' AS "KOSZT MATERIALU", TO_CHAR(ROUND(AVG(ZLECENIE.ZYSK),2))||'Z�' AS "ZYSK" 
FROM ZLECENIE 
GROUP BY ROLLUP(ZLECENIE.TYP_ZLECENIA_ID_TYPU,ZLECENIE.CZAS_TRWANIA);

--2. ROLLUP

SELECT NVL(TO_CHAR(ZLECENIE.PRACOWNIK_ID_PRACOWNIKA),' ') AS "ID PRACOWNIKA", NVL(TO_CHAR(ZLECENIE.TYP_ZLECENIA_ID_TYPU),' ') AS "TYP ZLECENIA",  
NVL(TO_CHAR(ZLECENIE.CZAS_TRWANIA),' ') AS "CZAS TRWANIA", ROUND(COUNT(ZLECENIE.ID_ZLECENIA),0) AS "ILOSC ZLECEN", TO_CHAR(ROUND(SUM(ZLECENIE.KOSZT_MATERIALOW),2))||'Z�' AS "KOSZT MATERIALOW", TO_CHAR(ROUND(SUM(ZLECENIE.ZYSK),2))||'Z�' AS "ZYSK" 
FROM ZLECENIE 
GROUP BY ROLLUP(ZLECENIE.PRACOWNIK_ID_PRACOWNIKA,ZLECENIE.TYP_ZLECENIA_ID_TYPU,ZLECENIE.CZAS_TRWANIA);

--3. CUBE

SELECT NVL(TO_CHAR(ZLECENIE.PRACOWNIK_ID_PRACOWNIKA),' ') AS "ID PRACOWNIKA", NVL(TO_CHAR(ZLECENIE.TYP_ZLECENIA_ID_TYPU),' ') AS "TYP ZLECENIA", 
NVL(TO_CHAR(ZLECENIE.CZAS_TRWANIA),' ') AS "CZAS TRWANIA", ROUND(COUNT(ZLECENIE.KLIENT_ID_KLIENTA),0) AS "ILOSC KLIENTOW",
TO_CHAR(ROUND(AVG(ZLECENIE.ZYSK),2))||' Z�' AS "SREDNI ZYSK", TO_CHAR(ROUND(SUM(ZLECENIE.ZYSK),2))||' Z�' AS "SUMA ZYSKU" 
FROM ZLECENIE 
GROUP BY CUBE(ZLECENIE.PRACOWNIK_ID_PRACOWNIKA, ZLECENIE.TYP_ZLECENIA_ID_TYPU, ZLECENIE.CZAS_TRWANIA);

--4. CUBE

SELECT NVL(TO_CHAR(ZLECENIE.KLIENT_ID_KLIENTA),' ') AS "ID KLIENTA", NVL(TO_CHAR(ZLECENIE.TYP_ZLECENIA_ID_TYPU),' ') AS "TYP ZLECENIA",
ROUND(COUNT(ZLECENIE.ID_ZLECENIA),0) AS "ILOSC ZLECEN", TO_CHAR(ROUND(SUM(ZLECENIE.ZYSK),0))||' Z�' AS "ZYSK" 
FROM ZLECENIE 
GROUP BY CUBE(ZLECENIE.KLIENT_ID_KLIENTA,ZLECENIE.TYP_ZLECENIA_ID_TYPU);

--5. GROUPING SETS

SELECT NVL(TO_CHAR(ZLECENIE.KLIENT_ID_KLIENTA),' ') AS "ID KLIENTA" , NVL(TO_CHAR(ZLECENIE.CZAS_TRWANIA),' ') AS "CZAS TRWANIA", NVL(TO_CHAR(ZLECENIE.TYP_ZLECENIA_ID_TYPU),' ') AS "TYP USLUGI", 
NVL(TO_CHAR(ZLECENIE.PRACOWNIK_ID_PRACOWNIKA),' ') AS "ID PRACOWNIKA", TO_CHAR(SUM(ZLECENIE.CENA_USLUGI))||'Z�' AS "CENA USLUGI", TO_CHAR(SUM(ZLECENIE.ZYSK))||'Z�' AS "ZYSK"
FROM ZLECENIE 
GROUP BY GROUPING SETS(ZLECENIE.CZAS_TRWANIA, ZLECENIE.TYP_ZLECENIA_ID_TYPU, ZLECENIE.PRACOWNIK_ID_PRACOWNIKA,(ZLECENIE.KLIENT_ID_KLIENTA,ZLECENIE.TYP_ZLECENIA_ID_TYPU))
ORDER BY ZLECENIE.KLIENT_ID_KLIENTA,ZLECENIE.CZAS_TRWANIA,ZLECENIE.TYP_ZLECENIA_ID_TYPU,    ZLECENIE.PRACOWNIK_ID_PRACOWNIKA;

--6. GROUPING SETS

SELECT NVL(TO_CHAR(ZLECENIE.CZAS_TRWANIA),' ') AS "CZAS TRWANIA", NVL(TO_CHAR(ZLECENIE.TYP_ZLECENIA_ID_TYPU),' ') AS "TYP USLUGI", 
NVL(TO_CHAR(ZLECENIE.PRACOWNIK_ID_PRACOWNIKA),' ') AS "ID PRACOWNIKA", TO_CHAR(SUM(ZLECENIE.ZYSK))||'Z�' AS "ZYSK"
FROM ZLECENIE 
GROUP BY GROUPING SETS(ZLECENIE.CZAS_TRWANIA,(ZLECENIE.CZAS_TRWANIA, ZLECENIE.TYP_ZLECENIA_ID_TYPU), ZLECENIE.PRACOWNIK_ID_PRACOWNIKA)
ORDER BY ZLECENIE.CZAS_TRWANIA,ZLECENIE.TYP_ZLECENIA_ID_TYPU,ZLECENIE.PRACOWNIK_ID_PRACOWNIKA;

--7. OKNO RUCHOME

SELECT ROK.NUMER AS "ROK", MIESIAC.ID_MIESIACA AS "MIESIAC", TO_CHAR(SUM(ZLECENIE.ZYSK))||'Z�' AS "ZYSK",
TO_CHAR(NVL(TO_CHAR(LAG(SUM(ZLECENIE.ZYSK),1) OVER (ORDER BY ROK.NUMER, MIESIAC.ID_MIESIACA)),'---'))||'Z�' AS "LAG",
TO_CHAR(NVL(TO_CHAR(SUM(ZLECENIE.ZYSK) - (LAG(SUM(ZLECENIE.ZYSK),1) OVER (ORDER BY ROK.NUMER, MIESIAC.ID_MIESIACA))),'---'))||'Z�' AS "WZROST/SPADEK"
FROM ROK, MIESIAC, ZLECENIE, DATA
WHERE ROK.ID_ROKU = DATA.ROK_ID_ROKU 
AND MIESIAC.ID_MIESIACA = DATA.MIESIAC_ID_MIESIACA
AND DATA.ID_DATY = ZLECENIE.DATA_ID_DATY 
AND ROK.NUMER = 2015
GROUP BY ROK.NUMER, MIESIAC.ID_MIESIACA;

--8. OKNO RUCHOME

SELECT ROK.NUMER AS "ROK" ,MIESIAC.NAZWA AS "MIESIAC", 
TO_CHAR(SUM(ZLECENIE.ZYSK))||'Z�' AS "ZYSK",
TO_CHAR(SUM(SUM(ZLECENIE.ZYSK)) OVER (ORDER BY MIESIAC.ID_MIESIACA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))||'Z�' AS "SUMA KUMULACYJNA",
TO_CHAR(FIRST_VALUE(SUM(ZLECENIE.ZYSK)) OVER (ORDER BY MIESIAC.ID_MIESIACA ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING))||'Z�' AS "POPRZEDNI MIESIAC",
TO_CHAR(LAST_VALUE(SUM(ZLECENIE.ZYSK)) OVER (ORDER BY MIESIAC.ID_MIESIACA ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING))||'Z�' AS "KOLEJNY MIESIAC"
FROM ZLECENIE,MIESIAC,DATA,ROK 
WHERE MIESIAC.ID_MIESIACA = DATA.MIESIAC_ID_MIESIACA 
AND ROK.ID_ROKU = DATA.ROK_ID_ROKU 
AND DATA.ID_DATY = ZLECENIE.DATA_ID_DATY 
AND ROK.NUMER = 2015
GROUP BY ROK.ID_ROKU, MIESIAC.ID_MIESIACA, ROK.NUMER, MIESIAC.NAZWA 
ORDER BY ROK.NUMER,MIESIAC.ID_MIESIACA;

--9. OKNO RUCHOME

SELECT ROK.NUMER AS "ROK", KWARTAL.ID_KWARTALU AS "KWARTAL", PRACOWNIK.ID_PRACOWNIKA AS "ID",
COUNT(ZLECENIE.ID_ZLECENIA) AS "ILOSC OBSLUZONYCH KLIENTOW",
SUM(COUNT(ZLECENIE.ID_ZLECENIA)) OVER (PARTITION BY KWARTAL.ID_KWARTALU,ROK.NUMER ORDER BY KWARTAL.ID_KWARTALU ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "SUMA ZLECEN",
SUM(COUNT(ZLECENIE.ID_ZLECENIA)) OVER (PARTITION BY ROK.NUMER ORDER BY ROK.NUMER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "SUMA ZLECEN1",
TO_CHAR(SUM(ZLECENIE.ZYSK))||'Z�' AS "ZYSK",
TO_CHAR(SUM(SUM(ZLECENIE.ZYSK)) OVER (PARTITION BY KWARTAL.ID_KWARTALU,ROK.NUMER ORDER BY KWARTAL.ID_KWARTALU ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))||'Z�' AS "SUMA KUMULACYJNA",
TO_CHAR(SUM(SUM(ZLECENIE.ZYSK)) OVER (PARTITION BY ROK.NUMER ORDER BY ROK.NUMER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))||'Z�' AS "SUMA KUMULACYJNA1"
FROM ZLECENIE, ROK, DATA, KWARTAL, PRACOWNIK
WHERE ROK.ID_ROKU = DATA.ROK_ID_ROKU
AND KWARTAL.ID_KWARTALU = DATA.KWARTAL_ID_KWARTALU
AND DATA.ID_DATY = ZLECENIE.DATA_ID_DATY
AND PRACOWNIK.ID_PRACOWNIKA = ZLECENIE.PRACOWNIK_ID_PRACOWNIKA 
AND ROK.NUMER BETWEEN 2012 AND 2016
AND KWARTAL.ID_KWARTALU BETWEEN 1 AND 3
GROUP BY ROK.NUMER, KWARTAL.ID_KWARTALU, PRACOWNIK.ID_PRACOWNIKA
ORDER BY ROK.NUMER, KWARTAL.ID_KWARTALU;

--10. PARTYCJA OBLICZENIOWA

SELECT DISTINCT ZLECENIE.TYP_ZLECENIA_ID_TYPU AS "TYP ZLECENIA", PRACOWNIK.ID_PRACOWNIKA AS "ID PRACOWNIKA", 
TO_CHAR(ROUND(SUM(ZLECENIE.ZYSK) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU, PRACOWNIK.ID_PRACOWNIKA),2))||'Z�' AS "ZYSK", 
TO_CHAR(ROUND((100*SUM(ZLECENIE.ZYSK) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU, PRACOWNIK.ID_PRACOWNIKA)/SUM(ZLECENIE.ZYSK) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU)),2)||'%') AS "UDZIAL % W ZYSKU DLA TYPU",
TO_CHAR(ROUND(SUM(ZLECENIE.CENA_USLUGI) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU,PRACOWNIK.ID_PRACOWNIKA),2))||'Z�'AS "CENA USLUGI",
TO_CHAR(ROUND((100*SUM(ZLECENIE.CENA_USLUGI) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU, PRACOWNIK.ID_PRACOWNIKA)/SUM(ZLECENIE.CENA_USLUGI) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU)),2)||'%') AS "UDZIAL % W CENIE DLA TYPU",
TO_CHAR(ROUND(SUM(ZLECENIE.KOSZT_MATERIALOW) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU,PRACOWNIK.ID_PRACOWNIKA),2))||'Z�' AS "KOSZT MATERIALU",
TO_CHAR(ROUND((100*SUM(ZLECENIE.KOSZT_MATERIALOW) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU, PRACOWNIK.ID_PRACOWNIKA)/SUM(ZLECENIE.KOSZT_MATERIALOW) OVER (PARTITION BY ZLECENIE.TYP_ZLECENIA_ID_TYPU)),2)||'%') AS "UDZIAL % W MATERIALE DLA TYPU"
FROM ZLECENIE,PRACOWNIK, DATA, MIESIAC, ROK
WHERE PRACOWNIK.ID_PRACOWNIKA = ZLECENIE.PRACOWNIK_ID_PRACOWNIKA 
AND MIESIAC.ID_MIESIACA = DATA.MIESIAC_ID_MIESIACA
AND ROK.ID_ROKU = DATA.ROK_ID_ROKU
AND DATA.ID_DATY = ZLECENIE.DATA_ID_DATY
AND MIESIAC.ID_MIESIACA BETWEEN 1 AND 9
AND ROK.NUMER BETWEEN 2011 AND 2015
ORDER BY ZLECENIE.TYP_ZLECENIA_ID_TYPU, PRACOWNIK.ID_PRACOWNIKA;

--11. PARTYCJA OBLICZENIOWA

SELECT DISTINCT ROK.NUMER AS "ROK", KWARTAL.ID_KWARTALU AS "KWARTAL" , GRUPA_KLIENTELI.NAZWA_GRUPY AS "GRUPA KLIENTELI",
COUNT(ZLECENIE.ID_ZLECENIA) OVER (PARTITION BY ROK.NUMER,  KWARTAL.ID_KWARTALU , GRUPA_KLIENTELI.NAZWA_GRUPY) AS "ILOSC ZLECEN",
TO_CHAR(ROUND((100*COUNT(ZLECENIE.ID_ZLECENIA) OVER (PARTITION BY ROK.NUMER, KWARTAL.ID_KWARTALU, GRUPA_KLIENTELI.NAZWA_GRUPY)/COUNT(ZLECENIE.ID_ZLECENIA) OVER (PARTITION BY ROK.NUMER,KWARTAL.ID_KWARTALU)),2)||'%') AS "UDZIAL % DLA KWARTALU",
TO_CHAR(ROUND((100*COUNT(ZLECENIE.ID_ZLECENIA) OVER (PARTITION BY ROK.NUMER, KWARTAL.ID_KWARTALU, GRUPA_KLIENTELI.NAZWA_GRUPY)/COUNT(ZLECENIE.ID_ZLECENIA) OVER (PARTITION BY ROK.NUMER)),2)||'%') AS "UDZIAL % DLA ROKU"
FROM ROK, KWARTAL, GRUPA_KLIENTELI, DATA, KLIENT, ZLECENIE 
WHERE ROK.ID_ROKU = DATA.ROK_ID_ROKU 
AND KWARTAL.ID_KWARTALU  = DATA.KWARTAL_ID_KWARTALU
AND GRUPA_KLIENTELI.ID_GRUPY = KLIENT.GRUPA_KLIENTELI_ID_GRUPY 
AND DATA.ID_DATY = ZLECENIE.DATA_ID_DATY 
AND KLIENT.ID_KLIENTA = ZLECENIE.KLIENT_ID_KLIENTA
AND ROK.NUMER BETWEEN 2012 AND 2016
ORDER BY ROK.NUMER,KWARTAL.ID_KWARTALU ,GRUPA_KLIENTELI.NAZWA_GRUPY;

--12. RANKING

SELECT DZIEN_TYGODNIA.NAZWA AS "DZIEN", COUNT(ZLECENIE.ID_ZLECENIA) AS "ILOSC ZLECEN", 
DENSE_RANK() OVER (ORDER BY COUNT(ZLECENIE.ID_ZLECENIA) DESC) AS "RANKING"
FROM DZIEN_TYGODNIA,DATA,ZLECENIE, MIESIAC, ROK
WHERE DZIEN_TYGODNIA.ID_DNIA = DATA.DZIEN_TYGODNIA_ID_DNIA 
AND DATA.ID_DATY = ZLECENIE.DATA_ID_DATY
AND ROK.ID_ROKU = DATA.ROK_ID_ROKU 
AND MIESIAC.ID_MIESIACA = DATA.MIESIAC_ID_MIESIACA
AND ROK.NUMER BETWEEN 2011 AND 2014
AND MIESIAC.ID_MIESIACA BETWEEN 1 AND 9
GROUP BY DZIEN_TYGODNIA.NAZWA;

--13. RANKING

SELECT ZLECENIE.TYP_ZLECENIA_ID_TYPU AS "ID TYPU" ,TYP_ZLECENIA.NAZWA AS "NAZWA ZLECENIA", COUNT(ZLECENIE.KLIENT_ID_KLIENTA) AS "ILOSC KLIENTOW",
RANK() OVER (ORDER BY COUNT(ZLECENIE.KLIENT_ID_KLIENTA) DESC) AS "RANKING" FROM ZLECENIE,TYP_ZLECENIA,ROK,DATA, MIESIAC
WHERE TYP_ZLECENIA.ID_TYPU = ZLECENIE.TYP_ZLECENIA_ID_TYPU 
AND ROK.ID_ROKU = DATA.ROK_ID_ROKU 
AND MIESIAC.ID_MIESIACA = DATA.MIESIAC_ID_MIESIACA
AND DATA.ID_DATY = ZLECENIE.DATA_ID_DATY 
AND ROK.NUMER BETWEEN 2012 AND 2013
AND MIESIAC.ID_MIESIACA BETWEEN 1 AND 12
GROUP BY ZLECENIE.TYP_ZLECENIA_ID_TYPU,TYP_ZLECENIA.NAZWA;

--14. RANKING

SELECT PRACOWNIK.ID_PRACOWNIKA, PRACOWNIK.IMIE, PRACOWNIK.NAZWISKO, STANOWISKO.NAZWA, 
COUNT( ZLECENIE.ID_ZLECENIA) AS "ILOSC ZLECEN",
DENSE_RANK() OVER (ORDER BY COUNT(ZLECENIE.ID_ZLECENIA) DESC) AS "RANKING"
FROM PRACOWNIK, STANOWISKO, ZLECENIE, DATA, MIESIAC, ROK
WHERE STANOWISKO.ID_STANOWISKO = PRACOWNIK.STANOWISKO_ID_STANOWISKO
AND PRACOWNIK.ID_PRACOWNIKA = ZLECENIE.PRACOWNIK_ID_PRACOWNIKA
AND MIESIAC.ID_MIESIACA = DATA.MIESIAC_ID_MIESIACA
AND ROK.ID_ROKU = DATA.ROK_ID_ROKU
AND DATA.ID_DATY = ZLECENIE.DATA_ID_DATY
AND MIESIAC.ID_MIESIACA BETWEEN 1 AND 12
AND ROK.NUMER BETWEEN 2011 AND 2016
GROUP BY PRACOWNIK.ID_PRACOWNIKA, PRACOWNIK.IMIE, PRACOWNIK.NAZWISKO, STANOWISKO.NAZWA;