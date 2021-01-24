
import pytest

import brownie
import time
DURACION = 3
TIEMPO_INICIO = 5
INITIAL_VALUE = 1

@pytest.fixture
def apuestas1_contract(apuestas1, accounts):
    yield apuestas1.deploy(TIEMPO_INICIO,DURACION,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(apuestas1_contract,accounts):
    assert apuestas1_contract.inicial() == INITIAL_VALUE
    assert apuestas1_contract.casa() == accounts[0]
    assert apuestas1_contract.termina() == apuestas1_contract.empieza() + DURACION


def test_failed_transactions(apuestas1_contract, accounts):
    
    apuestas1_contract.apostar(1,1,{'from': accounts[2],'value':4})
    
    with brownie.reverts("Jugador"):
        apuestas1_contract.apostar(1,1,{'from': accounts[0],'value':0})
    
    
    with brownie.reverts("Apuesta positiva"):
        apuestas1_contract.apostar(1,1,{'from': accounts[1],'value':0})
        
    with brownie.reverts("Despues de empezar"):
        apuestas1_contract.mitad({'from': accounts[1],'value':0})
        
    time.sleep(5)
    with brownie.reverts("Antes de empezar"):
        apuestas1_contract.apostar(1,1,{'from': accounts[1],'value':0})
        
    with brownie.reverts("Casa"):
        apuestas1_contract.mitad({'from': accounts[1],'value':0})
    
    with brownie.reverts("Valor suficiente"):
        apuestas1_contract.mitad({'from': accounts[0],'value':0})
    
    with brownie.reverts("Despues de terminar"):
        apuestas1_contract.devolver(1,1,{'from': accounts[0]})
        
    time.sleep(4)
    
    with brownie.reverts("Casa"):
        apuestas1_contract.devolver(1,1,{'from': accounts[1]})
        
    with brownie.reverts("Ha invertido"):
        apuestas1_contract.devolver(1,1,{'from': accounts[0]})
    
    apuestas1_contract.mitad({'from': accounts[0],'value':100})
    
    with brownie.reverts("Valores positivos o 0"):
        apuestas1_contract.devolver(-1,1,{'from': accounts[0]})
    
    with brownie.reverts("Se han devuelto a todos"):
        apuestas1_contract.finalizacion({'from': accounts[0]})
    
