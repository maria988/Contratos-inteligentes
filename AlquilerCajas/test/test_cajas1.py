
import pytest

import brownie

CAJAS = 2
INITIAL_VALUE = 100
MENS = 20
TIEMPO_DISFRUTE = 30

TIEMPO_PAGAR = 10
FIANZA = 10

@pytest.fixture
def cajas1_contract(Cajas1, accounts):
    yield Cajas1.deploy(CAJAS,MENS,TIEMPO_DISFRUTE,TIEMPO_PAGAR,FIANZA,{'from': accounts[0]})

def test_inicial(cajas1_contract,accounts):
    assert cajas1_contract.fianza() == FIANZA
    assert cajas1_contract.tienda() == accounts[0]
    assert cajas1_contract.cajas() == CAJAS
    assert cajas1_contract.mensualidad() == MENS
    assert cajas1_contract.tiempo_disfrute()== TIEMPO_DISFRUTE
    assert cajas1_contract.tiempo_pagar() == TIEMPO_PAGAR
    
def test_events(cajas1_contract, accounts):
    cajas1_contract.alquilar({'from': accounts[1],'value':30})
    cajas1_contract.asignarllave(213,0,{'from': accounts[0]})
    tx1 = cajas1_contract.cambio(0)
    cajas1_contract.alquilar({'from': accounts[2],'value':30})
    cajas1_contract.asignarllave(215,1,{'from': accounts[0]})
    tx2 = cajas1_contract.cambio(1)
    
    assert len(tx1.events) == 2
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor']== accounts[0]
    assert tx1.events[0]['valor']== 20
    assert tx1.events[1]['receptor'] == accounts[1]
    assert tx1.events[1]['emisor'] == accounts[0]
    assert tx1.events[1]['clave_'] == 213
    
    assert len(tx2.events) == 2
    assert tx2.events[0]['emisor'] == accounts[2]
    assert tx2.events[0]['receptor']== accounts[0]
    assert tx2.events[0]['valor']== 20
    assert tx2.events[1]['receptor'] == accounts[2]
    assert tx2.events[1]['emisor'] == accounts[0]
    assert tx2.events[1]['clave_'] == 215


def test_failed_transactions(cajas1_contract, accounts):
    # Try to set the storage to a negative amount
    cajas1_contract.alquilar({'from': accounts[3],'value':30})
    cajas1_contract.alquilar({'from': accounts[1],'value':30})
    with brownie.reverts("Suficientes cajas"):
        cajas1_contract.alquilar( {"from": accounts[4],'value':30})

    
