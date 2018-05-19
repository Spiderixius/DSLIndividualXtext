/*
 * generated by Xtext 2.10.0
 */ 
package com.metagamedsl.generator

import com.metagamedsl.metaGameLanguage.Action
import com.metagamedsl.metaGameLanguage.Add
import com.metagamedsl.metaGameLanguage.And
import com.metagamedsl.metaGameLanguage.Argument
import com.metagamedsl.metaGameLanguage.Assignment
import com.metagamedsl.metaGameLanguage.BoolExp
import com.metagamedsl.metaGameLanguage.BooleanValue
import com.metagamedsl.metaGameLanguage.Comparison
import com.metagamedsl.metaGameLanguage.Coordinates
import com.metagamedsl.metaGameLanguage.Dec
import com.metagamedsl.metaGameLanguage.Declaration
import com.metagamedsl.metaGameLanguage.Div
import com.metagamedsl.metaGameLanguage.DivEq
import com.metagamedsl.metaGameLanguage.Eq
import com.metagamedsl.metaGameLanguage.Expression
import com.metagamedsl.metaGameLanguage.Game
import com.metagamedsl.metaGameLanguage.Inc
import com.metagamedsl.metaGameLanguage.InternalFunction
import com.metagamedsl.metaGameLanguage.LocalVariable
import com.metagamedsl.metaGameLanguage.Location
import com.metagamedsl.metaGameLanguage.MinusEq
import com.metagamedsl.metaGameLanguage.Mult
import com.metagamedsl.metaGameLanguage.MultEq
import com.metagamedsl.metaGameLanguage.Number
import com.metagamedsl.metaGameLanguage.NumberExp
import com.metagamedsl.metaGameLanguage.Object
import com.metagamedsl.metaGameLanguage.Or
import com.metagamedsl.metaGameLanguage.PlusEq
import com.metagamedsl.metaGameLanguage.Property
import com.metagamedsl.metaGameLanguage.Proposition
import com.metagamedsl.metaGameLanguage.Sub
import com.metagamedsl.metaGameLanguage.VarActionCondition
import com.metagamedsl.metaGameLanguage.VarWinCondition
import com.metagamedsl.metaGameLanguage.Variable
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.metagamedsl.metaGameLanguage.Parenthesis

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 * 
 * Game Labyrint
 * Object Agent1 (1,4) Agent2 (3,1)  
    isAgent = true
Location Wall (1,1) (2,3) (2,4) (3,2) (3,3)   
    isWall = true
Object Goal (4,4)
 * 
 * 
 * 
 */
class MetaGameLanguageGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		resource.allContents.filter(Game).forEach[generateGameFile(fsa)]
 	}
  
 	def generateGameFile(Game game, IFileSystemAccess2 fsa) {
  		fsa.generateFile(game.name+".java",game.generateGame)
 	}
  
 	def CharSequence generateGame(Game game)'''
import com.frameworkdsl.gameframework.*;
import com.frameworkdsl.fluentapi.callback.*;
import com.frameworkdsl.metamodel.graph.*;
import com.frameworkdsl.fluentapi.*;
import com.frameworkdsl.metamodel.MachineMetaModel;
import com.frameworkdsl.objects.Location;
import com.frameworkdsl.objects.Position;
import com.frameworkdsl.objects.Object;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
 
public class �game.name� extends FluentMachine {
	
	�FOR a:game.actions� 
    public class �a.declaration.name�Action implements IAction{
        private IInternalFunction _iInternalFunction;;
        
        public �a.declaration.name�Action(IInternalFunction iInternalFunction){
            _iInternalFunction = iInternalFunction;
        }
        
        public �a.declaration.name�Action(){}
        
        @Override 
		public boolean execute(Map<String, java.lang.Object> args, MachineMetaModel model) {
			boolean executionAllowed = true;
			Map<String, java.lang.Object> map = model.getExtendedStateVariables();
			MetaGameGraph graph = model.getGraph();
			�FOR arg:a.declaration.args?.arguments�
			�arg.getArgumentType(a, game.declarations)� �arg.name� = (�arg.getArgumentType(a, game.declarations) �)args.get("�arg.name�");
			�ENDFOR�
			�FOR c:a.condition.conditions?.conditions�
			executionAllowed &= �c.generateCondition�;
			�ENDFOR�
			if(executionAllowed) {
				�FOR f:a.effect.effects?.effects�
				�f.generateEffect�
				�ENDFOR�
			}
 			
 			return executionAllowed;		
		}
		
		@Override
		public List<String> getTypeList() {
			List<String> types = new ArrayList<>();
			�FOR arg:a.declaration.args?.arguments�
				types.add("�arg.name�");
			�ENDFOR�	
			return types;
		}
	}
	    
	�ENDFOR�	
    	
    private MachineMetaModel _machineMetaModel;
    private List<Event> events = new ArrayList<>();
    private �game.name�(){
        build();
        run();
    }
    
    public void build(){
    	Map<String, java.lang.Object> map = metamodel.getExtendedStateVariables();
        // Create object tree
        global("�game.name�")
        �FOR f: game.fields��f.generateProperty("")��ENDFOR�
        �FOR d: game.declarations��d.generateDeclaration��ENDFOR�
        �IF game.winningState !== null�
        .winningState(new IWinningCallback() {
        	
        	@Override
        	public boolean execute(MachineMetaModel model, IInternalFunction _iInternalFunction) {
        		Map<String, java.lang.Object> map = model.getExtendedStateVariables();
        		boolean hasWon = true;
        		�FOR c:game.winningState?.conditions.cond�
        		hasWon &= �c.generateWinCondition(game.declarations)�;
        		�ENDFOR�
        		return hasWon;
        	}
        	
        	}) 
       	�ENDIF�;
        // Create events
        �FOR e: game.executions�
        events.add(new Event(new ArrayList<java.lang.Object>() {{�FOR args :e.executionArgs?.executionArgs� add(�args.generateExecutionArgs�);�ENDFOR� }}, new �e.action_name.name�Action(new FrameworkPredefinedInternalFunction())));
        �ENDFOR�    
        
	    
	    _machineMetaModel = metamodel;
    }

    public void run(){
		IFramework framework = new GameFramework(new GameFrameworkFactory(_machineMetaModel, new FrameworkPredefinedInternalFunction(),�game.grid.size.x�,�game.grid.size.y�));
		framework.run(events);
    }

    public static void main(String [] args)
    {
        new �game.name�();
    }
}'''
	// Performs type inference on argument properties in action
	// Ex: player -> Object
	def String getArgumentType(Argument arg, Action action, List<Declaration> declarations) {
		var targetProperty = ""
		for (c:action.condition.conditions?.conditions) {
			if (c instanceof VarActionCondition) {
				var custom = c as VarActionCondition
				if (custom.argument.name.equals(arg.name)) {
					targetProperty = custom.property.name
				}
			}
		}
		if (targetProperty == "") throw new Exception("Type inference of "+arg.name + " could not be resolved - because its properties is not used in action")
		// Find type by properties in declarations
		var type = ""
		for (d:declarations) {
			var currentType = d.getType(targetProperty)
			if (!currentType.equals("")) {
				type = currentType
			}
		}
		if (type.equals("")) throw new Exception("Type inference of "+arg.name+" could not be resolved - because property "+targetProperty+" needs to exist on an object or location")
		type
 
 	}
 	
	// Generates code for a boolean property condition
	// Ex: player.isAgent -> (map.containsKey(player.getName()+".isAgent") && (boolean)map.get(player.getName()+".isAgent")) || !map.containsKey(player.getName()+".isAgent")
 	def dispatch CharSequence generateCondition(VarActionCondition c) 
	 '''(map.containsKey(�c.argument.name�.getName()+".�c.property.name�") && �IF c.not !== null�!�ENDIF��c.property.getPropertyType�map.get(�c.argument.name�.getName()+".�c.property.name�"))
	 		|| !map.containsKey(�c.argument.name�.getName()+".�c.property.name�")''' 
	
	// Generates code for an internal function
	// Ex: isNeighbor(player, next) -> _iInternalFunction.isNeighbor(player, next);
	def dispatch CharSequence generateCondition(InternalFunction f) 
	 '''�IF f.not !== null�!�ENDIF�_iInternalFunction.�f.internal_name�(�FOR arg:f.arguments?.arguments SEPARATOR ', '��arg.name��ENDFOR�)'''
	
	// Generates code for a proposition
	// Ex: player.score < totalScore -> (int)map.get(player.getName()+".score")<(int)map.get("totalScore")
	def dispatch CharSequence generateCondition(Proposition p) {
		p.generateBoolExp(true)
	}
	
	// Generates code for an internal function as effect
	// Ex: goTo(player, next) -> _iInternalFunction.goTo(player, next);
	def dispatch CharSequence generateEffect(InternalFunction f) 
	 '''�IF f.not !== null�!�ENDIF� _iInternalFunction.�f.internal_name�(�FOR arg:f.arguments?.arguments SEPARATOR ', '��arg.name��ENDFOR�);'''
	
	// Generates code for an assignment effect
	// player.score++ -> if (map.containsKey(player.getName()+".score")) map.put(player.getName()+".score", (int)map.get(player.getName()+".score") + 1);
	//					 graph.execute(player.getName()+".score");
	def dispatch CharSequence generateEffect(Assignment a) 
	'''if (map.containsKey(�IF a.dec_name !== null��a.dec_name�.getName()+".�ELSE�"�ENDIF��a.assign_name.name�")) map.put(�IF a.dec_name !== null��a.dec_name�.getName()+".�ELSE�"�ENDIF��a.assign_name.name�", �a.generateAssignment�);
	graph.execute(�IF a.dec_name !== null��a.dec_name�.getName()+".�ELSE�"�ENDIF��a.assign_name.name�");
	'''
	
	// Generates code for declaring a property in build method
	// number score = Agent1.score + Agent2.score -> varProperty("score", new String[] {"Agent1.score", "Agent2.score"}, new IPropertyCallback() {
	//												 	@Override
	//												    public void execute() {
	//														map.put("score", (int)map.get("Agent1.score") + (int)map.get("Agent2.score"));
	//													});
    def String generateProperty(Property p, String prefix) {
    	var vars = p.getVariables
    	if (vars.size() > 0) {  		
    		'''.varProperty("�p.name�", new String[] {�FOR v:vars SEPARATOR ', '�"�v�"�ENDFOR�}, new IPropertyCallback() {
            @Override
            public void execute() {
                map.put("�IF !prefix.equals("")��prefix�.�ENDIF��p.name�", �IF p instanceof BoolExp��(p as BoolExp).bool_exp.generateBoolExp(false)��ELSE��(p as NumberExp).math_exp.generateMathExp(false)��ENDIF�);
            }
        })'''
    	} else {
	    	switch p {
	    		BoolExp: ".boolProperty(\""+ p.name +"\", " + p.bool_exp.generateBoolExp(false) + ")" // .boolProperty("isAgent", true)
	    		NumberExp: ".intProperty(\""+ p.name +"\", " + p.math_exp.generateMathExp(false) + ")" //.intProperty("score", 0)
	    		default: throw new Error("Invalid expression")
	    	}	
    	}
    } 	
    
    // Generates object declaration
    // Ex: Object Agent1 (0,0) -> .object("Agent1", new Position(0,0))
	def dispatch String generateDeclaration(Object declaration)'''
	    �FOR objectDeclaration: declaration.declarations� 
	      .object("�objectDeclaration.name�",�objectDeclaration.coordinates.x�,�objectDeclaration.coordinates.y�)�FOR p: declaration.properties��p.generateProperty(objectDeclaration.name)��ENDFOR�
	    �ENDFOR�
	'''
	
	// Generates location declaration
	// Ex: Location Wall (0,0) (0,2) -> .location("Wall", new ArrayList<Position>() {{ add(new Position(0,0); add(new Position(0,2)}})
	def dispatch String generateDeclaration(Location declaration)'''
	    �FOR locationDeclaration: declaration.declarations� 
	      .location("�locationDeclaration.name�", new ArrayList<Position>()  {{�FOR coordinate: locationDeclaration.coordinates� add(new Position(�coordinate.x�,�coordinate.y�));�ENDFOR�}})�FOR p: declaration.properties��p.generateProperty(locationDeclaration.name)��ENDFOR�
	    �ENDFOR�
	'''    
	
	// Generates Winning State conditions
	// Ex: Agent1.isAgent -> (map.containsKey("Agent1.isAgent") && (boolean)map.get("Agent1.isAgent"))|| !map.containsKey("Agent1.isAgent");
    def dispatch CharSequence generateWinCondition(VarWinCondition c, List<Declaration> declarations) 
	 '''(map.containsKey("�c.var_name�.�c.property.name�") && �IF c.not !== null�!�ENDIF��c.property.getPropertyType�map.get("�c.var_name�.�c.property.name�"))
	 		|| !map.containsKey("�c.var_name�.�c.property.name�")''' 
	
	// Generates Winning state internal function as condition	
	// isHere(Agent1, Goal) -> _iInternalFunction.isHere(model.getObject("Agent1"), model.getObject("Goal"));
	def dispatch CharSequence generateWinCondition(InternalFunction f, List<Declaration> declarations) 
	'''�IF f.not !== null�!�ENDIF� _iInternalFunction.�f.internal_name�(�FOR arg:f.arguments?.arguments SEPARATOR ', '�model.get�arg.name.getDeclarationType(declarations)�("�arg.name�")�ENDFOR�)'''
	 
	// Generates Winning state proposition condition
	// Ex: Agent1.keys + Agent2.keys == 4 -> (((int)map.get("Agent1.keys")+(int)map.get("Agent2.keys")) == (4));
	def dispatch CharSequence generateWinCondition(Proposition c, List<Declaration> declarations) {
		c.generateBoolExp(false)
	}
	
	// Generates Execution Arguments for events from an argument name or coordinates
	def dispatch String generateExecutionArgs(Argument argument)'''"�argument.name�"'''
	def dispatch String generateExecutionArgs(Coordinates coordinates) '''new Position(�coordinates.x�, �coordinates.y�)'''
 
 	// Returns the declaration type by name
 	// Ex: "Agent1" -> "Object"
 	def String getDeclarationType(String name, List<Declaration> declarations) {
 		for (d:declarations) {
 			var type = d.findDeclarationNames(name)
 			if (type !== "") return type
 		}
 		throw new Exception("name is not declared as an object or location")
 	}
 	def dispatch String findDeclarationNames(Object o, String name) {
 		for (dec:o.declarations) {
 			if (dec.name.equals(name)) return "Object"
 		}
 		""
 	}
 	def dispatch String findDeclarationNames(Location l, String name) {
 		for (dec:l.declarations) {
 			if (dec.name.equals(name)) return "Location"
 		}
 		""
 	}
 
 	// Returns Argument type (Object or Location) for type inference based on existing properties using dispatch methods
 	def dispatch String getType(Object object, String property) {
	 	for (p:object.properties) {
	 		if (p.name.equals(property)) {
	 			return "Object"
	 		}
	 	}
		""
	 }
	def dispatch String getType(Location location, String property) {
	 	for (p:location.properties) {
	 		if (p.name.equals(property)) {
	 			return "Location"
	 		}
	 	}
		""
	}
	
	// Returns the type for property casting from the extended state variables map
   	def String getPropertyType(Property p) {
    	switch p {
    		BoolExp: "(boolean)"
    		NumberExp: "(int)"
    		default: throw new Error("Invalid expression")
    	}
    } 	
    
    // Generates an assignment based on equality operators
    // Ex: player.score += 5 -> (int)map.get(player.getName()+".score") + 5
	def CharSequence generateAssignment(Assignment a) {
		var isArg = true
		switch a.op {
			Eq: '''�a.exp.generateMathExp(isArg)�'''
			PlusEq: '''(int)map.get(�IF a.dec_name !== null��a.dec_name�.getName()+".�ENDIF��a.assign_name.name�") + �a.exp.generateMathExp(isArg)�'''
			MinusEq: '''(int)map.get(�IF a.dec_name !== null��a.dec_name�.getName()+".�ENDIF��a.assign_name.name�") - �a.exp.generateMathExp(isArg)�'''
			MultEq: '''(int)map.get(�IF a.dec_name !== null��a.dec_name�.getName()+".�ENDIF��a.assign_name.name�") * �a.exp.generateMathExp(isArg)�'''
			DivEq: '''(int)map.get(�IF a.dec_name !== null��a.dec_name�.getName()+".�ENDIF��a.assign_name.name�") / �a.exp.generateMathExp(isArg)�'''
			Inc: '''(int)map.get(�IF a.dec_name !== null��a.dec_name�.getName()+".�ENDIF��a.assign_name.name�") + 1'''
			Dec: '''(int)map.get(�IF a.dec_name !== null��a.dec_name�.getName()+".�ENDIF��a.assign_name.name�") - 1'''
		}
	}
	
	// Returns a list of properties the given property is dependent on
	// Ex: number score = Agent1.score + Agent2.score -> new ArrayList<String> { "Agent1.score", "Agent2.score" }
    def List<String> getVariables(Property p) {
    	switch p {
    		BoolExp: p.bool_exp.getBoolVars
    		NumberExp: p.math_exp.getMathVars
    		default: throw new Error("Invalid expression")
    	}
    }
    
    // Returns a list with names on dependent boolean properties by concatenating the lists from Propositions or Expressions
    def List<String> getBoolVars(Proposition p) {
    	var list = new ArrayList<String>()
    	switch p {
    		And: { 	list.addAll(p.left.getBoolVars)
	    			list.addAll(p.right.getBoolVars) }
	      	Or: { 	list.addAll(p.left.getBoolVars)
	    			list.addAll(p.right.getBoolVars) } 
	      	Comparison: { 	list.addAll(p.left.getMathVars)
	    					list.addAll(p.right.getMathVars) }
    	}
    	list
    }
    
    // Returns a list with names on dependent integer properties by concatenating the lists from Expressions  
    def List<String> getMathVars(Expression e) {
    	var list = new ArrayList<String>()
    	switch e {
    		Add: { 	list.addAll(e.left.getMathVars)
	    			list.addAll(e.right.getMathVars) }
	    	Sub: { 	list.addAll(e.left.getMathVars)
	    			list.addAll(e.right.getMathVars) }
	    	Mult: { list.addAll(e.left.getMathVars)
	    			list.addAll(e.right.getMathVars) }
	    	Div: { 	list.addAll(e.left.getMathVars)
	    			list.addAll(e.right.getMathVars) }
	    	Parenthesis: list.addAll(e.exp.getMathVars)
	        LocalVariable: list.add(e.var_local +"."+ e.var_prop.name) // Ex: parameters to varProperty
	        Variable: list.add(e.var_prop.name) //
	    }
	    list
    }
    
    // Generates a boolean expression from a proposition
    // Ex: 5 - 1 < 10 + 2 -> ((5-1)<(10+2))
    def String generateBoolExp(Proposition exp, boolean isArg) {
	    switch exp {
	    	And: exp.left.generateBoolExp(isArg)+"&&"+exp.right.generateBoolExp(isArg)
	      	Or: exp.left.generateBoolExp(isArg)+"||"+exp.right.generateBoolExp(isArg)
	      	Comparison: "(("+exp.left.generateMathExp(isArg)+") "+exp.operator+" ("+exp.right.generateMathExp(isArg)+"))"
	      	BooleanValue: exp.bool
	      	default: throw new Error("Invalid proposition")
	    }
	}
	
	// Generates a math expression from an expression and a parameter denoting if a variable should refer to its 
	// argument name (inside actions) or declared name (in object/location declaration)
	// Ex (isArg=false): Agent1.score + Agent2.score -> (int)map.get("Agent1.score") + (int)map.get("Agent2.score")
	// Ex (isArg=true): player.score -> (int)map.get(player.getName()+".score")
	def String generateMathExp(Expression exp, boolean isArg) {
	    switch exp {
	    	Add: exp.left.generateMathExp(isArg)+"+"+exp.right.generateMathExp(isArg)
	    	Sub: exp.left.generateMathExp(isArg)+"-"+exp.right.generateMathExp(isArg)
	    	Mult: exp.left.generateMathExp(isArg)+"*"+exp.right.generateMathExp(isArg)
	    	Div: exp.left.generateMathExp(isArg)+"/"+exp.right.generateMathExp(isArg)
	    	Parenthesis: "("+ exp.exp.generateMathExp(isArg) + ")"
	        Number: Integer.toString(exp.value)
	        LocalVariable: {
	        	var local = ""
	        	if (isArg) {
	        		local = exp.var_local+".getName()+\""
	        	} else {
	        		local = "\""+exp.var_local
	        	}
	        	exp.var_prop.getPropertyType + "map.get("+ local +"."+ exp.var_prop.name+"\")" // Ex: (boolean)map.get(player.getName()+".isAgent"))
	        }
	        Variable: exp.var_prop.getPropertyType + "map.get(\""+exp.var_prop.name+"\")" // Ex: (int)map.get("Agent1.score")+(int)map.get("Agent2.score")
	      	default: throw new Error("Invalid Math Expression")
	    }
	}  
	
  
}