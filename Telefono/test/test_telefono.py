
import pytest

import brownie

import time

PRECIOTIEMPO = 1
ESTABLLAMADA = 3
TELEFONO = "925459402"
CANTIDAD = 3
TELEFONO2 = "913930183"
@pytest.fixture
def telefono_contract(telefono, accounts):
    yield telefono.deploy(PRECIOTIEMPO,ESTABLLAMADA,TELEFONO,{'from': accounts[0]})

def test_inicial(telefono_contract,accounts):
    assert telefono_contract.empresa() == accounts[0]
    assert telefono_contract.precioTiempo() == PRECIOTIEMPO
    assert telefono_contract.estabLlamada() == ESTABLLAMADA
    assert telefono_contract.telefono() == TELEFONO

def test_uso(telefono_contract,accounts):
    telefono_contract.recargar(TELEFONO,accounts[0],{'from':accounts[1],'value':10})
    assert telefono_contract.balance() == 10
    telefono_contract.llamar(TELEFONO,{'from':accounts[1]})
    telefono_contract.colgar(TELEFONO,{'from':accounts[1]})
    assert telefono_contract.balance() == 7
    telefono_contract.llamar(TELEFONO,{'from':accounts[1]})
    time.sleep(8)
    telefono_contract.cortar(TELEFONO,{'from':accounts[0]})
    assert telefono_contract.balance() ==0
    
def test_failed_transactions(telefono_contract, accounts):
    
    with brownie.reverts("Empresa"):
        telefono_contract.recargar(TELEFONO, accounts[3],{'from':accounts[1],'value':CANTIDAD})
    
    with brownie.reverts("Telefono correcto"):
        telefono_contract.recargar(TELEFONO2, accounts[0],{'from':accounts[1],'value':CANTIDAD})
   
    with brownie.reverts("Valor positivo"):
        telefono_contract.recargar(TELEFONO, accounts[0],{'from':accounts[1],'value':0})
         
    telefono_contract.recargar(TELEFONO, accounts[0],{'from':accounts[1],'value':CANTIDAD})
    
    with brownie.reverts("Telefono correcto"):
        telefono_contract.saldo(TELEFONO2,{'from':accounts[1]})
        
    assert telefono_contract.saldo(TELEFONO,{'from':accounts[1]}) == CANTIDAD
    
    with brownie.reverts("Telefono correcto"):
        telefono_contract.colgar(TELEFONO2,{'from':accounts[0]})
     
    with brownie.reverts("Llamando"):
        telefono_contract.colgar(TELEFONO,{'from':accounts[0]})
        
    with brownie.reverts("Telefono correcto"):
        telefono_contract.llamar(TELEFONO2,{'from':accounts[0]})
        
    with brownie.reverts("Suficiente"):
        telefono_contract.llamar(TELEFONO,{'from':accounts[0]})
    
    with brownie.reverts("Telefono correcto"):
        telefono_contract.cortar(TELEFONO2,{'from':accounts[0]})
    
    with brownie.reverts("Empresa"):
        telefono_contract.cortar(TELEFONO,{'from':accounts[2]})
        
    with brownie.reverts("Llamando"):
        telefono_contract.cortar(TELEFONO,{'from':accounts[0]})
    
    telefono_contract.recargar(TELEFONO, accounts[0],{'from':accounts[1],'value':CANTIDAD})
    telefono_contract.llamar(TELEFONO,{'from':accounts[0]})
    
    with brownie.reverts("Superado"):
        telefono_contract.cortar(TELEFONO,{'from':accounts[0]})
        
    time.sleep(5)
    
    telefono_contract.cortar(TELEFONO,{'from':accounts[0]})
    
    assert telefono_contract.saldo(TELEFONO,{'from':accounts[1]}) == 0
