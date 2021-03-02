
import pytest

import brownie

import math

PRECIO = 2
PORC_LINEA = 10
PORC_BINGO = 50
INITIAL_VALUE = 100

@pytest.fixture
def bingo1_contract(bingo1, accounts):
    yield bingo1.deploy(PRECIO,PORC_LINEA,PORC_BINGO,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(bingo1_contract,accounts):
    assert bingo1_contract.casa() == accounts[0]
    assert bingo1_contract.precio() == PRECIO
    assert bingo1_contract.porc_linea() == PORC_LINEA
    assert bingo1_contract.porc_bingo() == PORC_BINGO
    assert bingo1_contract.acumulado() == INITIAL_VALUE   
    
def test_uso(bingo1_contract,accounts):
    bingo1_contract.comprarcarton({'from':accounts[1],'value':PRECIO})
    bingo1_contract.comprarcarton({'from':accounts[2],'value':2*PRECIO})
    assert bingo1_contract.acumulado() == PRECIO *3 + INITIAL_VALUE
    assert bingo1_contract.ganarconbingo({'from':accounts[1]}) == ((bingo1_contract.acumulado()* PORC_BINGO)/100)
    assert bingo1_contract.ganarconlinea({'from':accounts[1]}) == ((bingo1_contract.acumulado() * PORC_LINEA)/100)
    
    bingo1_contract.empezar({'from':accounts[0]})
    assert bingo1_contract.empezado()
    bingo1_contract.ponernumero(2,{'from':accounts[0]})
    bingo1_contract.ponernumero(60,{'from':accounts[0]})
    bingo1_contract.ponernumero(71,{'from':accounts[0]})
    bingo1_contract.ponernumero(30,{'from':accounts[0]})
    bingo1_contract.ponernumero(4,{'from':accounts[0]})
    
    bingo1_contract.linea(2,60,71,30,4,{'from':accounts[1]})
    assert bingo1_contract.yalinea()
    assert bingo1_contract.balance() == math.ceil(bingo1_contract.acumulado() - ((bingo1_contract.acumulado() * PORC_LINEA)/100))
    
    bingo1_contract.ponernumero(6,{'from':accounts[0]})
    bingo1_contract.ponernumero(78,{'from':accounts[0]})
    bingo1_contract.ponernumero(22,{'from':accounts[0]})
    bingo1_contract.ponernumero(1,{'from':accounts[0]})
    bingo1_contract.ponernumero(79,{'from':accounts[0]})
    bingo1_contract.ponernumero(50,{'from':accounts[0]})
    bingo1_contract.ponernumero(59,{'from':accounts[0]})
    bingo1_contract.ponernumero(89,{'from':accounts[0]})
    bingo1_contract.ponernumero(5,{'from':accounts[0]})
    bingo1_contract.ponernumero(33,{'from':accounts[0]})
    
    bingo1_contract.bingo(2,60,71,30,4,6,78,22,1,79,50,59,89,5,33,{'from':accounts[2]})

def test_failed_transactions(bingo1_contract, accounts):
    bingo1_contract.comprarcarton({'from': accounts[3],'value':4})
    
    with brownie.reverts("Jugador"):
        bingo1_contract.comprarcarton({'from': accounts[0],'value':4})
        
    with brownie.reverts("Manda ether"):
        bingo1_contract.comprarcarton({'from': accounts[1],'value':1})
    
    with brownie.reverts("Ha empezado"):
        bingo1_contract.ponernumero(12,{'from': accounts[0]})
    
    with brownie.reverts("Ha empezado"):
        bingo1_contract.linea(1,4,21,56,89,{'from': accounts[0]})
    
    with brownie.reverts("Ha empezado"):
        bingo1_contract.bingo(1,4,21,56,89,12,65,8,54,3,45,25,86,76,11,{'from': accounts[1]})
    
    bingo1_contract.empezar({'from': accounts[0]})
    
    with brownie.reverts("No ha empezado"):
        bingo1_contract.comprarcarton({'from': accounts[1],'value':4})
        
    with brownie.reverts("Casa"):
        bingo1_contract.ponernumero(3,{'from': accounts[2]})
        
    with brownie.reverts("Mayor que 0"):
        bingo1_contract.ponernumero(0,{'from': accounts[0]})
        
    with brownie.reverts("Menor que 101"):
        bingo1_contract.ponernumero(102,{'from': accounts[0]})
    
    bingo1_contract.ponernumero(2,{'from': accounts[0]})
    
    with brownie.reverts("No ha salido"):
        bingo1_contract.ponernumero(2,{'from': accounts[0]})
    
    with brownie.reverts("Casa"):
        bingo1_contract.empezar({'from': accounts[1]})
     
    with brownie.reverts("Jugador"):
        bingo1_contract.linea(1,4,21,56,89,{'from': accounts[0]})
    
    with brownie.reverts("Han salido"):
        bingo1_contract.linea(1,4,21,56,89,{'from': accounts[1]})
    
    with brownie.reverts("Han salido"):
        bingo1_contract.linea(2,4,21,56,89,{'from': accounts[1]})
        
    bingo1_contract.ponernumero(4,{'from':accounts[0]})
    with brownie.reverts("Han salido"):
        bingo1_contract.linea(2,4,21,56,89,{'from': accounts[1]})
    
    
    with brownie.reverts("Todos distintos"):
        bingo1_contract.linea(2,2,2,2,2,{'from': accounts[1]})
        
    bingo1_contract.ponernumero(21,{'from':accounts[0]})
    bingo1_contract.ponernumero(56,{'from':accounts[0]})     
    bingo1_contract.ponernumero(89,{'from':accounts[0]})
    
    
    
    bingo1_contract.linea(2,4,21,56,89,{'from': accounts[1]})
    
    
    with brownie.reverts("No se ha cantado linea"):
        bingo1_contract.linea(2,4,21,56,89,{'from': accounts[1]})
    
    with brownie.reverts("Jugador"):
        bingo1_contract.bingo(2,4,21,56,89,12,65,8,54,3,45,25,86,76,11,{'from': accounts[0]})
        
    with brownie.reverts("Han salido"):
        bingo1_contract.bingo(2,4,21,56,89,12,65,8,54,3,45,25,86,76,11,{'from': accounts[1]})
    
    
    with brownie.reverts("Todos distintos"):
        bingo1_contract.bingo(2,4,21,56,89,2,4,21,56,89,2,4,21,56,89,{'from': accounts[1]})
    
    bingo1_contract.ponernumero(12,{'from':accounts[0]})
    bingo1_contract.ponernumero(65,{'from':accounts[0]})
    bingo1_contract.ponernumero(8,{'from':accounts[0]})
    bingo1_contract.ponernumero(54,{'from':accounts[0]})     
    bingo1_contract.ponernumero(3,{'from':accounts[0]})
    bingo1_contract.ponernumero(45,{'from':accounts[0]})
    bingo1_contract.ponernumero(25,{'from':accounts[0]})     
    bingo1_contract.ponernumero(86,{'from':accounts[0]})
    bingo1_contract.ponernumero(76,{'from':accounts[0]})
    bingo1_contract.ponernumero(11,{'from':accounts[0]})
    
    
    bingo1_contract.bingo(2,4,21,56,89,12,65,8,54,3,45,25,86,76,11,{'from': accounts[1]})
