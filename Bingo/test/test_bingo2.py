
import pytest

import brownie
import time

PRECIO = 2
PORC_LINEA = 10
PORC_BINGO = 50
INITIAL_VALUE = 100

@pytest.fixture
def bingo2_contract(bingo2, accounts):
    yield bingo2.deploy(PRECIO,PORC_LINEA,PORC_BINGO,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(bingo2_contract,accounts):
    assert bingo2_contract.casa() == accounts[0]
    assert bingo2_contract.precio() == PRECIO
    assert bingo2_contract.porc_linea() == PORC_LINEA
    assert bingo2_contract.porc_bingo() == PORC_BINGO
    assert bingo2_contract.acumulado() == INITIAL_VALUE   

def test_failed_transactions(bingo2_contract, accounts):
    bingo2_contract.comprarcarton({'from': accounts[3],'value':4})
    
    with brownie.reverts("Jugador"):
        bingo2_contract.comprarcarton({'from': accounts[0],'value':4})
        
    with brownie.reverts("Manda ether"):
        bingo2_contract.comprarcarton({'from': accounts[1],'value':1})
    
    with brownie.reverts("Ha empezado"):
        bingo2_contract.ponernumero(12,{'from': accounts[0]})
    
    with brownie.reverts("Ha empezado"):
        bingo2_contract.linea(1,4,21,56,89,{'from': accounts[0]})
    
    with brownie.reverts("Ha empezado"):
        bingo2_contract.bingo(1,4,21,56,89,12,65,8,54,3,45,25,86,76,11,{'from': accounts[1]})
    
    bingo2_contract.empezar({'from': accounts[0]})
    
    with brownie.reverts("No ha empezado"):
        bingo2_contract.comprarcarton({'from': accounts[1],'value':4})
        
    with brownie.reverts("Casa"):
        bingo2_contract.ponernumero(3,{'from': accounts[2]})
        
    with brownie.reverts("Mayor que 0"):
        bingo2_contract.ponernumero(0,{'from': accounts[0]})
        
    with brownie.reverts("Menor que 101"):
        bingo2_contract.ponernumero(102,{'from': accounts[0]})
    
    bingo2_contract.ponernumero(2,{'from': accounts[0]})
    
    with brownie.reverts("No ha salido"):
        bingo2_contract.ponernumero(2,{'from': accounts[0]})
    
    with brownie.reverts("Casa"):
        bingo2_contract.empezar({'from': accounts[1]})
     
    with brownie.reverts("Jugador"):
        bingo2_contract.linea(1,4,21,56,89,{'from': accounts[0]})
    
    with brownie.reverts("Han salido"):
        bingo2_contract.linea(1,4,21,56,89,{'from': accounts[1]})
    
    with brownie.reverts("Han salido"):
        bingo2_contract.linea(2,4,21,56,89,{'from': accounts[1]})
        
    bingo2_contract.ponernumero(4,{'from':accounts[0]})
    with brownie.reverts("Han salido"):
        bingo2_contract.linea(2,4,21,56,89,{'from': accounts[1]})
    
    
    with brownie.reverts("Todos distintos"):
        bingo2_contract.linea(2,2,2,2,2,{'from': accounts[1]})
        
    bingo2_contract.ponernumero(21,{'from':accounts[0]})
    bingo2_contract.ponernumero(56,{'from':accounts[0]})     
    bingo2_contract.ponernumero(89,{'from':accounts[0]})
    
    
    
    bingo2_contract.linea(2,4,21,56,89,{'from': accounts[1]})
    
    
    with brownie.reverts("No se ha cantado linea"):
        bingo2_contract.linea(2,4,21,56,89,{'from': accounts[1]})
    
    with brownie.reverts("Jugador"):
        bingo2_contract.bingo(2,4,21,56,89,12,65,8,54,3,45,25,86,76,11,{'from': accounts[0]})
        
    with brownie.reverts("Han salido"):
        bingo2_contract.bingo(2,4,21,56,89,12,65,8,54,3,45,25,86,76,11,{'from': accounts[1]})
    
    
    with brownie.reverts("Todos distintos"):
        bingo2_contract.bingo(2,4,21,56,89,2,4,21,56,89,2,4,21,56,89,{'from': accounts[1]})
    
    bingo2_contract.ponernumero(12,{'from':accounts[0]})
    bingo2_contract.ponernumero(65,{'from':accounts[0]})
    bingo2_contract.ponernumero(8,{'from':accounts[0]})
    bingo2_contract.ponernumero(54,{'from':accounts[0]})     
    bingo2_contract.ponernumero(3,{'from':accounts[0]})
    bingo2_contract.ponernumero(45,{'from':accounts[0]})
    bingo2_contract.ponernumero(25,{'from':accounts[0]})     
    bingo2_contract.ponernumero(86,{'from':accounts[0]})
    bingo2_contract.ponernumero(76,{'from':accounts[0]})
    bingo2_contract.ponernumero(11,{'from':accounts[0]})
    
    
    bingo2_contract.bingo(2,4,21,56,89,12,65,8,54,3,45,25,86,76,11,{'from': accounts[1]})
    
    
