
import pytest

import brownie

DURACION = 90
TIEMPO_INICIO = 10
INITIAL_VALUE = 200

@pytest.fixture
def apuestas2_contract(Apuestas2, accounts):
    yield Apuestas2.deploy(TIEMPO_INICIO,DURACION,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(apuestas2_contract,accounts):
    assert apuestas2_contract.inicial() == INITIAL_VALUE
    assert apuestas2_contract.casa() == accounts[0]
    assert apuestas2_contract.termina() == apuestas2_contract.empieza()+DURACION

    
def test_failed_transactions(apuestas2_contract, accounts):
    
    with brownie.reverts("Jugador"):
        apuestas2_contract.apostar(1,0,{'from': accounts[0],'value':50})
    
    
    with brownie.reverts("Apuesta positiva"):
        apuestas2_contract.apostar(1,1,{'from': accounts[1],'value':0})
