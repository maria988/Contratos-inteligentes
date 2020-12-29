
import pytest

import brownie

DURACION = 1
TIEMPO_INICIO = 100
INITIAL_VALUE = 200

@pytest.fixture
def apuestas1_contract(Apuestas1, accounts):
    yield Apuestas1.deploy(TIEMPO_INICIO,DURACION,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(apuestas1_contract,accounts):
    assert apuestas1_contract.inicial() == INITIAL_VALUE
    assert apuestas1_contract.casa() == accounts[0]
    assert apuestas1_contract.termina() == apuestas1_contract.empieza()+DURACION


def test_failed_transactions(apuestas1_contract, accounts):
    
    with brownie.reverts("Jugador"):
        apuestas1_contract.apostar(1,1,{'from': accounts[0],'value':0})
    
    
    with brownie.reverts("Apuesta positiva"):
        apuestas1_contract.apostar(1,1,{'from': accounts[1],'value':0})
