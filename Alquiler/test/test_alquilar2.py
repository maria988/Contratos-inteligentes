
import pytest

import brownie

INITIAL_VALUE = 100
MENS = 200
TIEMPO = 30
TIEMPO_CONTRATO = 90
CLAVE = 234

@pytest.fixture
def alquiler2_contract(Alquiler2, accounts):
    yield Alquiler2.deploy(MENS,TIEMPO,TIEMPO_CONTRATO,CLAVE,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(alquiler2_contract,accounts):
    assert alquiler2_contract.fianza() == INITIAL_VALUE
    assert alquiler2_contract.arrendador() == accounts[0]
    assert alquiler2_contract.mensualidad() == MENS
    assert alquiler2_contract.tiempo()==TIEMPO
    assert alquiler2_contract.tiempo_contrato() == TIEMPO_CONTRATO
    
def test_events(alquiler2_contract, accounts):
    tx1 =alquiler2_contract.alquilar({'from': accounts[1],'value':300})
    
    # Check log contents
    assert len(tx1.events) == 2
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor']== accounts[0]
    assert tx1.events[0]['valor']== 200
    assert tx1.events[1]['receptor'] == accounts[1]
    assert tx1.events[1]['emisor'] == accounts[0]
    assert tx1.events[1]['clave_'] == CLAVE

def test_failed_transactions(alquiler2_contract, accounts):
    # Try to set the storage to a negative amount
    with brownie.reverts("Suficiente"):
        alquiler2_contract.alquilar( {"from": accounts[1],'value':100})

    assert alquiler2_contract.alquilada() == False
    
    
   
