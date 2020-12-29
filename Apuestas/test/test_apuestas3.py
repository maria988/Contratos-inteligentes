
import pytest

import brownie

DURACION = 90
TIEMPO_INICIO = 10
INITIAL_VALUE = 200

@pytest.fixture
def apuestas3_contract(Apuestas3, accounts):
    yield Apuestas3.deploy(TIEMPO_INICIO,DURACION,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(apuestas3_contract,accounts):
    assert apuestas3_contract.inicial() == INITIAL_VALUE
    assert apuestas3_contract.casa() == accounts[0]
    assert apuestas3_contract.termina() == apuestas3_contract.empieza()+DURACION

    
def test_failed_transactions(apuestas3_contract, accounts):
    
    with brownie.reverts("Jugador"):
        apuestas3_contract.apostar(1,0,{'from': accounts[0],'value':50})
    
    
    with brownie.reverts("Apuesta positiva"):
        apuestas3_contract.apostar(1,1,{'from': accounts[1],'value':0})
