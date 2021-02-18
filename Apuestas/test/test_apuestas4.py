
import pytest

import brownie
import time

DURACION = 3
TIEMPO_INICIO = 5
INITIAL_VALUE = 1

@pytest.fixture
def apuestas4_contract(Apuestas4, accounts):
    yield Apuestas4.deploy(TIEMPO_INICIO,DURACION,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(apuestas4_contract,accounts):
    assert apuestas4_contract.inicial() == INITIAL_VALUE
    assert apuestas4_contract.casa() == accounts[0]
    assert apuestas4_contract.termina() == apuestas4_contract.empieza()+DURACION

def test_uso(apuestas4_contract,accounts):
    apuestas4_contract.apostar(1,1,{'from': accounts[2],'value':4})
    apuestas4_contract.apostar(1,0,{'from': accounts[3],'value':6})
    apuestas4_contract.apostar(0,0,{'from': accounts[2],'value':10})
    apuestas4_contract.apostar(1,1,{'from': accounts[4],'value':2})
    time.sleep(5)
    apuestas4_contract.mitad({'from':accounts[0],'value':10})
    assert apuestas4_contract.empezado({'from':accounts[1]})
    assert apuestas4_contract.terminado({'from':accounts[1]}) == False
    assert apuestas4_contract.ganar((accounts[2],1,1,4),{'from':accounts[2]}) == 6
    assert apuestas4_contract.ganar((accounts[3],1,0,6),{'from':accounts[3]}) == 9
    assert apuestas4_contract.ganar((accounts[4],1,1,2),{'from':accounts[4]}) == 3
    time.sleep(3)
    apuestas4_contract.ganadores(1,1,{'from':accounts[0]})
    
    assert apuestas4_contract.ganado((accounts[4],1,1,2),{'from':accounts[4]}) 
    assert not apuestas4_contract.ganado((accounts[3],1,0,6),{'from':accounts[3]})
    apuestas4_contract.devolver({'from':accounts[0]})
    
def test_failed_transactions(apuestas4_contract, accounts):
    apuestas4_contract.apostar(1,1,{'from': accounts[2],'value':4})
    
    with brownie.reverts("Jugador"):
        apuestas4_contract.apostar(1,0,{'from': accounts[0],'value':50})
    
    
    with brownie.reverts("Apuesta positiva"):
        apuestas4_contract.apostar(1,1,{'from': accounts[1],'value':0})
        
    with brownie.reverts("Despues de empezar"):
        apuestas4_contract.mitad({'from': accounts[1],'value':0})
        
    with brownie.reverts("Casa"):
        apuestas4_contract.necesario({'from': accounts[1]})    
    
    with brownie.reverts("Despues de empezar"):
        apuestas4_contract.necesario({'from': accounts[0]})
        
    time.sleep(5)
    with brownie.reverts("Antes de empezar"):
        apuestas4_contract.apostar(1,1,{'from': accounts[1],'value':0})
        
    with brownie.reverts("Casa"):
        apuestas4_contract.mitad({'from': accounts[1],'value':0})
    
    with brownie.reverts("Valor suficiente"):
        apuestas4_contract.mitad({'from': accounts[0],'value':0})
        
    with brownie.reverts("Casa"):
        apuestas4_contract.ganadores(1,1,{'from': accounts[1]})  
    
    with brownie.reverts("Despues de terminar"):
        apuestas4_contract.ganadores(1,1,{'from': accounts[0]}) 
    
        
    time.sleep(4)
    
    
    with brownie.reverts("Apuntados"):
        apuestas4_contract.ganado((accounts[1],1,1,20),{'from':accounts[1]}) 
        
    with brownie.reverts("Apuntados"):
        apuestas4_contract.devolver({'from': accounts[0]}) 
        
    apuestas4_contract.ganadores(1,1,{'from': accounts[0]}) 
    
    with brownie.reverts("No apuntados"):
        apuestas4_contract.ganadores(1,1,{'from': accounts[0]})    
        
    with brownie.reverts("Casa"):
        apuestas4_contract.devolver({'from': accounts[1]})
        
    with brownie.reverts("Ha invertido"):
        apuestas4_contract.devolver({'from': accounts[0]})
    
    apuestas4_contract.mitad({'from': accounts[0],'value':100})
