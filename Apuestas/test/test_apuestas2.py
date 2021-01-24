
import pytest

import brownie
import time
DURACION = 3
TIEMPO_INICIO = 5
INITIAL_VALUE = 1

@pytest.fixture
def apuestas2_contract(apuestas2, accounts):
    yield apuestas2.deploy(TIEMPO_INICIO,DURACION,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(apuestas2_contract,accounts):
    assert apuestas2_contract.inicial() == INITIAL_VALUE
    assert apuestas2_contract.casa() == accounts[0]
    assert apuestas2_contract.termina() == apuestas2_contract.empieza()+DURACION

    
def test_failed_transactions(apuestas2_contract, accounts):
    apuestas2_contract.apostar(1,1,{'from': accounts[2],'value':4})
    with brownie.reverts("Jugador"):
        apuestas2_contract.apostar(1,1,{'from': accounts[0],'value':4})
    
    
    with brownie.reverts("Apuesta positiva"):
        apuestas2_contract.apostar(1,1,{'from': accounts[1],'value':0})
        
    with brownie.reverts("Despues de empezar"):
        apuestas2_contract.mitad({'from': accounts[1],'value':0})
        
    time.sleep(5)
    with brownie.reverts("Antes de empezar"):
        apuestas2_contract.apostar(1,1,{'from': accounts[1],'value':0})
        
    with brownie.reverts("Casa"):
        apuestas2_contract.mitad({'from': accounts[1],'value':0})
    
    with brownie.reverts("Valor suficiente"):
        apuestas2_contract.mitad({'from': accounts[0],'value':0})
    
    with brownie.reverts("Despues de terminar"):
        apuestas2_contract.devolver(1,1,{'from': accounts[0]})
        
    time.sleep(4)
    
    with brownie.reverts("Casa"):
        apuestas2_contract.devolver(1,1,{'from': accounts[1]})
        
    with brownie.reverts("Ha invertido"):
        apuestas2_contract.devolver(1,1,{'from': accounts[0]})
    
    apuestas2_contract.mitad({'from': accounts[0],'value':100})
    
    with brownie.reverts("Valores positivos o 0"):
        apuestas2_contract.devolver(-1,1,{'from': accounts[0]})
    
    with brownie.reverts("Se han devuelto a todos"):
        apuestas2_contract.finalizacion({'from': accounts[0]})
