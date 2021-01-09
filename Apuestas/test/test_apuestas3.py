
import pytest

import brownie
import time
DURACION = 3
TIEMPO_INICIO = 5
INITIAL_VALUE = 1

@pytest.fixture
def apuestas3_contract(Apuestas3, accounts):
    yield Apuestas3.deploy(TIEMPO_INICIO,DURACION,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(apuestas3_contract,accounts):
    assert apuestas3_contract.inicial() == INITIAL_VALUE
    assert apuestas3_contract.casa() == accounts[0]
    assert apuestas3_contract.termina() == apuestas3_contract.empieza()+DURACION

    
def test_failed_transactions(apuestas3_contract, accounts):
    apuestas3_contract.apostar(1,1,{'from': accounts[2],'value':4})
    
    with brownie.reverts("Jugador"):
        apuestas3_contract.apostar(1,0,{'from': accounts[0],'value':50})
    
    
    with brownie.reverts("Apuesta positiva"):
        apuestas3_contract.apostar(1,1,{'from': accounts[1],'value':0})
        
    with brownie.reverts("Despues de empezar"):
        apuestas3_contract.mitad({'from': accounts[1],'value':0})
        
    with brownie.reverts("Casa"):
        apuestas3_contract.necesario({'from': accounts[1]})    
    
    with brownie.reverts("Despues de empezar"):
        apuestas3_contract.necesario({'from': accounts[0]})
        
    time.sleep(5)
    with brownie.reverts("Antes de empezar"):
        apuestas3_contract.apostar(1,1,{'from': accounts[1],'value':0})
        
    with brownie.reverts("Casa"):
        apuestas3_contract.mitad({'from': accounts[1],'value':0})
    
    with brownie.reverts("Valor suficiente"):
        apuestas3_contract.mitad({'from': accounts[0],'value':0})
    
    with brownie.reverts("Despues de terminar"):
        apuestas3_contract.devolver({'from': accounts[0]})
        
    with brownie.reverts("Casa"):
        apuestas3_contract.ganadores(1,1,{'from': accounts[1]})  
    
    with brownie.reverts("Despues de terminar"):
        apuestas3_contract.ganadores(1,1,{'from': accounts[0]}) 
    
    with brownie.reverts("Despues de terminar"):
        apuestas3_contract.ganar((accounts[1],1,1,20),{'from':accounts[1]}) 
        
    time.sleep(4)
    
    with brownie.reverts("Casa"):
        apuestas3_contract.devolver({'from': accounts[1]})
        
    with brownie.reverts("Ha invertido"):
        apuestas3_contract.devolver({'from': accounts[0]})
    
    apuestas3_contract.mitad({'from': accounts[0],'value':100})
    
    with brownie.reverts("Se han devuelto a todos"):
        apuestas3_contract.finalizacion({'from': accounts[0]})
