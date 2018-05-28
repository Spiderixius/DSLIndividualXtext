/*
 * generated by Xtext 2.12.0
 */
package com.metagamedsl.validation

import com.metagamedsl.metaGameLanguage.ObjectDeclaration
import com.metagamedsl.metaGameLanguage.Game
import com.metagamedsl.metaGameLanguage.GridSize
import com.metagamedsl.metaGameLanguage.MetaGameLanguagePackage
import org.eclipse.xtext.validation.Check
import com.metagamedsl.metaGameLanguage.Property
import java.util.HashMap
import com.metagamedsl.metaGameLanguage.Object
import com.metagamedsl.metaGameLanguage.Declaration
import com.metagamedsl.metaGameLanguage.Coordinates
import com.metagamedsl.metaGameLanguage.LocationDeclaration
import com.metagamedsl.metaGameLanguage.Location
import com.metagamedsl.metaGameLanguage.WinningState
import com.metagamedsl.metaGameLanguage.WinningCondition
import com.metagamedsl.metaGameLanguage.WinningConditions
import com.metagamedsl.metaGameLanguage.VarWinCondition

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class MetaGameLanguageValidator extends AbstractMetaGameLanguageValidator {
	public static val INVALID_NAME = "invalidName"
	public static val DUPLICATE_NAME = "duplicateName"
	public static val MIN_GRID_VALUE = 0
	public static val MAX_GRID_VALUE = 10
	private var objectMap = new HashMap<String, ObjectDeclaration>
	private var locationMap = new HashMap<String, LocationDeclaration>

	/**
	 * The method checks whether the name of the game starts with a capital letter.
	 * @param Game Allows access to the representation of the Game object.
	 */
	@Check
	def void checkNameStartsWithCapital(Game game) {
		/*
		 * Names should be capitalized! 
		 * 
		 * Game adventureQuest    << Should give a warning
		 */
		var literal = MetaGameLanguagePackage.Literals.GAME__NAME
		if (!Character.isUpperCase(game.name.charAt(0))) {
			warning("Name " + game.name + " should start with a capital.", literal, INVALID_NAME)
		}
	}

	/**
	 * The method checks whether the x and y grid constraints are being violated.
	 * @param GridSize Allows access to the representation of the Grid Size object.
	 */
	@Check
	def void checkGridCoordinates(GridSize grid) {
		/*
		 * Restrict Grid size to 1 and 10 (Randomly chosen)
		 * 
		 * Grid size(11,1)         << Should give error  
		 */
		// Variables
		var x = grid.size.x
		var y = grid.size.y
		var gridSize = MetaGameLanguagePackage.Literals.GRID_SIZE__SIZE

		if (x < MIN_GRID_VALUE || y < MIN_GRID_VALUE) {
			error("Grid size must be at least " + MIN_GRID_VALUE + ".", gridSize)
		} else if (x > MAX_GRID_VALUE || y > MAX_GRID_VALUE) {
			error("Grid size must be " + MAX_GRID_VALUE + " or under.", gridSize)
		}
	}

	/**
	 * Validate the positions of objects and locations compared to the currently set grid size.
	 * @param
	 */
	@Check
	def void checkCoordinatesComparedToGrid(Game game) {

		/*
		 * If Grid size is set to 10,10 then coordinates in other objects/locations 
		 * shouldn't be able to declare coordinates such as 30,10, since 30 exceeds
		 * 10
		 * 
		 * Grid Size(10,10)
		 * 
		 * Object P1 (14,10)        << Should give an error on x coordinate
		 */
		for (Declaration d : game.declarations) {
			switch (d) {
				Object: {
					traverseToDeclarationCoordinates(game, d)
				}
				Location: {
					traverseToDeclarationCoordinates(game, d)
				}
				default: {
					throw new Exception("No such declaration.")
				}
			}
		}
	}

	/**
	 * Everyone like to be unique, therefore objects and locations should have unique names.
	 * Furthermore attributes within each object/location should also be unique
	 */
	@Check
	def void checkFieldsAreUniqueName(Game game) {
		/*
		 * The following should give an error of existing name
		 * 
		 * number i = 10             << Should give error
		 * number i = 5              << Should give error
		 */
		var map = new HashMap<String, Property>
		var literal = MetaGameLanguagePackage.Literals.PROPERTY__NAME

		for (Property p : game.fields) {
			if (map.containsKey(p.name)) {
				error("Field name " + p.name + " must be unique.", p, literal, DUPLICATE_NAME)
				error("Field name " + p.name + " must be unique.", map.get(p.name), literal, DUPLICATE_NAME)
			} else {
				map.put(p.name, p)
			}
		}
	}

	// Du har delt din med mig
	@Check
	def void checkDeclarationsAreUniqueName(Game game) {
		/*
		 * Objects should have unique names
		 * 
		 * Object P1(1,3) P1(3,2)    << Should give error
		 * 	...
		 * 
		 * Object P1(5,3)            << Should give error
		 */
		objectMap = new HashMap<String, ObjectDeclaration>
		locationMap = new HashMap<String, LocationDeclaration>
		for (Declaration d : game.declarations) {
			switch (d) {
				Object: {
					traverseToDeclarationName(game, d)
				}
				Location: {
					traverseToDeclarationName(game, d)
				}
				default: {
					throw new Exception("No such declaration.")
				}
			}
		}
	}

	@Check
	def void checkFieldCircularity(Game game) {
		/*
		 * Should not be able to say:
		 * number i = k
		 * number k = i      << Circular reference
		 * 
		 */
		//
	}

	@Check
	def void checkPropertyUniqueName(Game game) {
		/*
		 * The following should give an error
		 * 
		 * Object P1(3,3)
		 * 	truth value isAgent = true     << Should give error
		 * 	truth value isAgent = true     << Should give error
		 */
		for (Declaration d : game.declarations) {
			switch (d) {
				Object: {
					traverseToDeclarationProptery(game, d)
				}
				Location: {
					traverseToDeclarationProptery(game, d)
				}
				default: {
					throw new Exception("No such declaration.")
				}
			}
		}
	}

	@Check
	def void checkUnexistingObjectPropertyIsBeingReferenced(Game game) {
		/* 
		 * You shouldn't be able to reference something that is not declared inside an object
		 * 
		 * number i = 10
		 * number d = P2.i        << Should give error, i exists but not in Object P2
		 * Object P2(3,2)
		 * 	number d = 5
		 */
		// Get all properties   
		// Check if properties declared outside of Object/Location are being referenced in Object/Location
	}

	@Check
	def void checkPositionToOnlyTakesObjectandLocation() {
		/*
		 * Allow PositionTo to only take Object and Location (in that order, and only one of each)
		 * 
		 * Action Move(agent, next)
		 * 	Condition agent.isAgent, isNeighbor(agent, next), !next.isWall 
		 * 	Effect PositionTo(next, agent)    << Should give error 
		 */
	}

	@Check
	def void checkActionHasDeclaration(Game game) {
	}

	@Check
	def void checkWinningStateHasDeclaration(Game game) {
		var literal = MetaGameLanguagePackage.Literals.VAR_WIN_CONDITION__VAR_NAME
		for (WinningCondition wc : game.winningState.conditions.cond) {
			if (wc instanceof VarWinCondition) {
				var w = wc as VarWinCondition
				if (objectMap.containsKey(w.var_name)) {
					error("Error no such name", w, literal)
				}
			}
		}
	}

	// //////////////////////////////////////////////////////////////////////////////////////////////
	// //////////////////////////////////////////////////////////////////////////////////////////////
	// //////////////////////////////// DISPATCH METHODS ////////////////////////////////////////////
	// //////////////////////////////////////////////////////////////////////////////////////////////
	// //////////////////////////////////////////////////////////////////////////////////////////////
	def dispatch void traverseToDeclarationCoordinates(Game game, Object object) {
		var grid_x = game.grid.size.x
		var grid_y = game.grid.size.y
		var literalObject = MetaGameLanguagePackage.Literals.OBJECT_DECLARATION__COORDINATES

		for (ObjectDeclaration od : object.declarations) {
			if (od.coordinates.x < MIN_GRID_VALUE || od.coordinates.y < MIN_GRID_VALUE) {
				error("Coordinate size must be " + MIN_GRID_VALUE + " or above", od, literalObject)
			} else if (od.coordinates.x > grid_x || od.coordinates.y > grid_y) {
				error(
					"Coordinate size (" + od.coordinates.x + ", " + od.coordinates.y +
						") must not be more than grid size (" + grid_x + ", " + grid_y + ").", od, literalObject)
			}
		}
	}

	def dispatch void traverseToDeclarationCoordinates(Game game, Location location) {
		var grid_x = game.grid.size.x
		var grid_y = game.grid.size.y
		var literalLocation = MetaGameLanguagePackage.Literals.LOCATION_DECLARATION__COORDINATES

		for (LocationDeclaration ld : location.declarations) {
			for (Coordinates c : ld.coordinates) {
				if (c.x < MIN_GRID_VALUE || c.y < MIN_GRID_VALUE) {
					error("Coordinate size must be " + MIN_GRID_VALUE + " or above", ld, literalLocation)
				} else if (c.x > grid_x || c.y > grid_y) {
					error(
						"Coordinate size (" + c.x + ", " + c.y + ") must not be more than grid size (" + grid_x + ", " +
							grid_y + ").", ld, literalLocation)
				}
			}
		}
	}

	def dispatch void traverseToDeclarationName(Game game, Object object) {

		var literalObject = MetaGameLanguagePackage.Literals.OBJECT_DECLARATION__NAME

		for (ObjectDeclaration od : object.declarations) {
			if (objectMap.containsKey(od.name)) {
				error("Field name " + od.name + " must be unique.", od, literalObject, DUPLICATE_NAME)
				error("Field name " + od.name + " must be unique.", objectMap.get(od.name), literalObject,
					DUPLICATE_NAME)
			} else {
				objectMap.put(od.name, od)
			}
		}
	}

	def dispatch void traverseToDeclarationName(Game game, Location location) {
		var literaLocation = MetaGameLanguagePackage.Literals.LOCATION_DECLARATION__NAME

		for (LocationDeclaration ld : location.declarations) {
			if (locationMap.containsKey(ld.name)) {
				error("Field name " + ld.name + " must be unique.", ld, literaLocation, DUPLICATE_NAME)
				error("Field name " + ld.name + " must be unique.", locationMap.get(ld.name), literaLocation,
					DUPLICATE_NAME)
			} else {
				locationMap.put(ld.name, ld)
			}
		}
	}

	def dispatch void traverseToDeclarationProptery(Game game, Object object) {
		var objectPropertyMap = new HashMap<String, Property>
		var literal = MetaGameLanguagePackage.Literals.PROPERTY__NAME

		for (Property p : object.properties) {
			if (objectPropertyMap.containsKey(p.name)) {
				error("Field name " + p.name + " must be unique.", p, literal, DUPLICATE_NAME)
				error("Field name " + p.name + " must be unique.", objectPropertyMap.get(p.name), literal,
					DUPLICATE_NAME)
			} else {
				objectPropertyMap.put(p.name, p)
			}
		}
	}

	def dispatch void traverseToDeclarationProptery(Game game, Location location) {
		var locationPropertyMap = new HashMap<String, Property>
		var literal = MetaGameLanguagePackage.Literals.PROPERTY__NAME

		for (Property p : location.properties) {
			if (locationPropertyMap.containsKey(p.name)) {
				error("Field name " + p.name + " must be unique.", p, literal, DUPLICATE_NAME)
				error("Field name " + p.name + " must be unique.", locationPropertyMap.get(p.name), literal,
					DUPLICATE_NAME)
			} else {
				locationPropertyMap.put(p.name, p)
			}
		}
	}
}
