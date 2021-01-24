
import pytest

import brownie
import time
PRECIO = 100

@pytest.fixture
def pagar_contract(pagarvarios, accounts):
    yield pagarvarios.deploy(PRECIO,{'from': accounts[0]})

def test_inicial(pagar_contract,accounts):
    assert pagar_contract.empresa() == accounts[0]
    assert pagar_contract.precio() == PRECIO

def test_realizacion(pagar_contract,accounts):
    pagar_contract.pagar(accounts[0],{'from':accounts[1],'value':20})
    pagar_contract.pagar(accounts[0],{'from':accounts[2],'value':50})
    pagar_contract.pagar(accounts[0],{'from':accounts[3],'value':30})
    assert pagar_contract.pagado()
    pagar_contract.producto({'from':accounts[1]})
    
def test_failed_transactions(pagar_contract, accounts):
    
    with brownie.reverts("Empresa"):
        pagar_contract.pagar(accounts[1],{'from':accounts[1]})
        
    with brownie.reverts("Cliente"):
        pagar_contract.pagar(accounts[0],{'from':accounts[0]})
    
    pagar_contract.pagar(accounts[0],{'from':accounts[1],'value':50})
    with brownie.reverts("Pagado"):
        pagar_contract.producto({'from':accounts[1]})
    
    pagar_contract.pagar(accounts[0],{'from':accounts[2],'value':50})
    with brownie.reverts("Ha pagado"):
        pagar_contract.producto({'from':accounts[3]})
