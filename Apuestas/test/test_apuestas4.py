
import pytest

import brownie

DURACION = 90
TIEMPO_INICIO = 10
INITIAL_VALUE = 200

@pytest.fixture
def apuestas4_contract(Apuestas4, accounts):
    yield Apuestas4.deploy(TIEMPO_INICIO,DURACION,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(apuestas4_contract,accounts):
    assert apuestas4_contract.inicial() == INITIAL_VALUE
    assert apuestas4_contract.casa() == accounts[0]
    assert apuestas4_contract.termina() == apuestas4_contract.empieza()+DURACION

    
def test_failed_transactions(apuestas4_contract, accounts):
    
    with brownie.reverts("Jugador"):
        apuestas4_contract.apostar(1,0,{'from': accounts[0],'value':50})
    
    
    with brownie.reverts("Apuesta positiva"):
        apuestas4_contract.apostar(1,1,{'from': accounts[1],'value':0})
