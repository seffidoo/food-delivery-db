#!/bin/bash
# ============================================================================
# TEST DIAGNOSTICO DEL DATABASE FOOD DELIVERY
# 
# Questo script esegue una serie di test per verificare il corretto
# funzionamento del database food_delivery_db, dimostrando le funzionalità
# di query, stored procedures e viste implementate.
# ============================================================================

# Configurazione MySQL
MYSQL_USER="root"
MYSQL_PASS="root"
MYSQL_DB="food_delivery_db"

# Contatori dei test
TESTS_TOTAL=0
TESTS_PASSED=0

# Colori per l'output
BOLD=$(tput bold)
RESET=$(tput sgr0)
BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)

# Funzione per eseguire una query e verificare il risultato
run_test() {
    local name="$1"
    local query="$2"
    local expected="$3"
    
    ((TESTS_TOTAL++))
    
    echo "${BOLD}${BLUE}$name${RESET}"
    echo "${BLUE}------------------------------------------------------------${RESET}"
    
    # Esegui la query
    result=$(mysql -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_DB -e "$query" 2>&1)
    
    # Mostra il risultato
    echo "$result"
    
    # Verifica se il risultato contiene la stringa attesa
    if echo "$result" | grep -q "$expected"; then
        echo "${GREEN}✓ Test superato!${RESET}"
        ((TESTS_PASSED++))
    else
        echo "${RED}✗ Test fallito!${RESET}"
        echo "${YELLOW}Ricerca: $expected${RESET}"
    fi
    echo ""
}

echo "${BOLD}${GREEN}==============================================${RESET}"
echo "${BOLD}${GREEN}  SISTEMA DATABASE FOOD DELIVERY - DIAGNOSTICA${RESET}"
echo "${BOLD}${GREEN}==============================================${RESET}"
echo ""

# Test 1: Verifica la connessione al database
run_test "Test 1: Connessione al database" \
"SHOW DATABASES;" \
"food_delivery_db"

# Test 2: Verifica tabelle principali
run_test "Test 2: Verifica delle tabelle principali" \
"SHOW TABLES;" \
"ristorante"

# Test 3: Query sui ristoranti
run_test "Test 3: Analisi ristoranti" \
"SELECT nome, tipoCucina, orarioApertura, orarioChiusura FROM ristorante;" \
"Pizzeria Napoli"

# Test 4: Query sui prodotti
run_test "Test 4: Prodotti nel menu" \
"SELECT p.nome, p.prezzo, p.categoria, r.nome FROM prodotto p JOIN ristorante r ON p.idRistorante = r.idRistorante ORDER BY r.nome, p.prezzo DESC;" \
"Sushi"

# Test 5: Verifica ordini esistenti
run_test "Test 5: Ordini esistenti" \
"SELECT o.idOrdine, o.costoTotale, u.nome, u.cognome, r.nome FROM ordine o JOIN utente u ON o.idUtente = u.idUtente JOIN ristorante r ON o.idRistorante = r.idRistorante;" \
"Margherita"

# Test 6: Verifica vista ristoranti con valutazioni
run_test "Test 6: Vista ristoranti con valutazioni" \
"SELECT * FROM vista_ristoranti_valutazioni;" \
"Pizzeria Napoli"

# Test 7: Test stored procedure - nuovo utente
run_test "Test 7: Registrazione nuovo utente" \
"CALL registra_nuovo_utente('Nuovo', 'Utente', 'nuovo.utente@test.com', 'password123', '3456789012', '1990-01-01', @id, @msg); SELECT @id, @msg;" \
"Utente registrato con successo"

# Test 8: Test stored procedure - nuovo prodotto
run_test "Test 8: Inserimento nuovo prodotto" \
"CALL inserisci_nuovo_prodotto('Test Prodotto', 'Descrizione di test', 12.99, 'Test', 1, @id, @msg); SELECT @id, @msg;" \
"Prodotto inserito con successo"

# Mostra il riepilogo dei test
echo "${BOLD}${GREEN}==============================================${RESET}"
if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo "${BOLD}${GREEN}  TUTTI I TEST COMPLETATI CON SUCCESSO!${RESET}"
else
    echo "${BOLD}${RED}  ATTENZIONE: ALCUNI TEST SONO FALLITI!${RESET}"
fi
echo "${BOLD}${GREEN}  $TESTS_PASSED/$TESTS_TOTAL TEST SUPERATI${RESET}"
echo "${BOLD}${GREEN}==============================================${RESET}"
