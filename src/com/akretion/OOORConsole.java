package com.akretion;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class OOORConsole
{
	public static void main(String [ ] args) {
		ScriptEngineManager manager = new ScriptEngineManager();
		final ScriptEngine scriptEngine = manager.getEngineByName("jruby");
		
		InputStreamReader reader = new InputStreamReader(OOORConsole.class.getResourceAsStream( "jirb_swing.rb" ));
		try {
			scriptEngine.eval("CLOSE_OPERATION='exit'");
			scriptEngine.eval(reader);
		} catch(ScriptException ex) {
		}
	}
}