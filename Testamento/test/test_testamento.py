import pytest

import brownie
import time

PRECIO = 50
DURACION = 5

HERENCIA = 150

@pytest.fixture
def testamento_contract(testamento, accounts):
    yield testamento.deploy(DURACION,{'from': accounts[0]})

def test_inicial(testamento_contract,accounts):
    assert testamento_contract.cliente() == accounts[0]
    assert testamento_contract.duracion() == DURACION

def test_event(testamento_contract,accounts):
    testamento_contract.anadir_herederos(accounts[2],{'from':accounts[0],'value':HERENCIA})
    testamento_contract.anadir_herederos(accounts[3],{'from':accounts[0],'value':HERENCIA})
    testamento_contract.anadir_herederos(accounts[4],{'from':accounts[0],'value':HERENCIA})
    testamento_contract.anadir_herederos(accounts[5],{'from':accounts[0],'value':HERENCIA})
    
    testamento_contract.cambiar_herencia(0,2*HERENCIA,{'from':accounts[0],'value':HERENCIA })
    
    testamento_contract.inicializar_herencia({'from':accounts[4]})
    
    time.sleep(6)
    assert testamento_contract.saber_herencia({'from':accounts[2]})== 2*HERENCIA
    tx1 = testamento_contract.cobrar_herencia({'from':accounts[4]})
    
    assert len(tx1.events) == 4
    assert tx1.events[0]['destinatario'] == accounts[2]
    assert tx1.events[0]['valor'] == HERENCIA *2
    assert tx1.events[1]['destinatario'] == accounts[3]
    assert tx1.events[1]['valor'] == HERENCIA
    assert tx1.events[2]['destinatario'] == accounts[4]
    assert tx1.events[2]['valor'] == HERENCIA
    assert tx1.events[3]['destinatario'] == accounts[5]
    assert tx1.events[3]['valor'] == HERENCIA 
def test_failed_transactions(testamento_contract, accounts):
     
    with brownie.reverts("Cliente"):
        testamento_contract.anadir_herederos(accounts[2],{'from':accounts[4],'value':HERENCIA})
    
    with brownie.reverts("Cliente"):
        testamento_contract.cambiar_herencia(2,HERENCIA,{'from':accounts[3],'value':HERENCIA})
        
    with brownie.reverts("Numero valido"):
        testamento_contract.cambiar_herencia(2,HERENCIA,{'from':accounts[0],'value':HERENCIA})
    
    testamento_contract.anadir_herederos(accounts[2],{'from':accounts[0],'value':HERENCIA})
    
    with brownie.reverts("Suficiente"):
        testamento_contract.cambiar_herencia(0,HERENCIA*9,{'from':accounts[0],'value':HERENCIA})
    
    with brownie.reverts("Empresa"):
        testamento_contract.inicializar_herencia({'from':accounts[3]})
    
    with brownie.reverts("Ha fallecido"):
        testamento_contract.cobrar_herencia({'from':accounts[0]})
        
    testamento_contract.inicializar_herencia({'from':accounts[2]})
    
    with brownie.reverts("No ha fallecido"):
        testamento_contract.inicializar_herencia({'from':accounts[2]})
    
    with brownie.reverts("Tope pasado"):
        testamento_contract.cobrar_herencia({'from':accounts[2]})
