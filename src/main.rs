use std::collections::HashMap;
use mlua::{Lua, Result};

struct Banco {
    dados: HashMap<String, String>,
    lua: Lua,
}

impl Banco {
    fn new() -> Self {
        let lua = Lua::new();
        lua.load(include_str!("funcoes.lua"))
            .exec()
            .expect("Erro ao carregar Lua");
        Banco {
            dados: HashMap::new(),
            lua,
        }
    }

    fn add(&mut self, chave: &str, valor: &str) -> Result<()> {
        let func: mlua::Function = self.lua.globals().get("add_transform")?;
        match func.call::<_, (bool, String)>((chave, valor))? {
            (true, val) => {
                self.dados.insert(chave.to_string(), val);
                Ok(())
            }
            (false, erro) => Err(mlua::Error::RuntimeError(erro)),
        }
    }

    fn get(&self, chave: &str) -> Result<String> {
        if let Some(valor) = self.dados.get(chave) {
            let func: mlua::Function = self.lua.globals().get("get_transform")?;
            let res: (bool, String) = func.call((chave, valor.clone()))?;
            if res.0 {
                Ok(res.1)
            } else {
                Err(mlua::Error::RuntimeError(res.1))
            }
        } else {
            Err(mlua::Error::RuntimeError("Chave não encontrada".to_string()))
        }
    }
}

fn main() -> Result<()> {
    let mut banco = Banco::new();

    //Exemplo CPF inválido
    // banco.add("cpf_teste", "11111111111")?;
    // println!("{}", banco.get("cpf_teste")?);

    //Exemplo CPF válido
    banco.add("cpf_teste", "52998224725")?;
    println!("{}", banco.get("cpf_teste")?);

    //Exemplo Data
    banco.add("data_nascimento_teste", "2001-05-27")?;
    println!("{}", banco.get("data_nascimento_teste")?);

    Ok(())
}

