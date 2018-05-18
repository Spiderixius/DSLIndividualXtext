/*
 * generated by Xtext 2.12.0
 */
package com.metagamedsl.validation

import org.eclipse.xtext.validation.Check
import com.metagamedsl.metaGameLanguage.Game
import com.metagamedsl.metaGameLanguage.MetaGameLanguagePackage
import org.eclipse.emf.ecore.EObject
import com.metagamedsl.metaGameLanguage.Coordinates
import com.metagamedsl.metaGameLanguage.GridSize
import com.metagamedsl.metaGameLanguage.Declaration

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class MetaGameLanguageValidator extends AbstractMetaGameLanguageValidator {
		
	/**
	 * The method checks whether the name of the game starts with a capital letter.
	 * @param Game Allows access to the representation of the Game object.
	 */
	@Check
    def void checkNameStartsWithCapital(Game game) {
        if (!Character.isUpperCase(game.name.charAt(0))) {
            warning("Name should start with a capital.", 
                MetaGameLanguagePackage.Literals.GAME__NAME)
        }
    }
    
    /**
     * The method checks whether the x and y grid constraints are being violated.
     * @param GridSize Allows access to the representation of the Grid Size object.
     */
    @Check
    def void checkGridCoordinates(GridSize grid) {
    	// Variables
    	var minValue = 1
    	var maxValue = 10
    	var x = grid.size.x
    	var y = grid.size.y
    	var gridSize = MetaGameLanguagePackage.eINSTANCE.gridSize_Size
    	
    	if(x < minValue || y < minValue){
    		error("Grid size must be at least 1.", gridSize)	
    	} else if(x > maxValue || y > maxValue) {
			error("Grid size must be 10 or under.", gridSize)
    	}
    }
	
	/**
	 * Validate the positions of objects and locations compared to the currently set grid size.
	 * @param
	 */
	@Check
	def void checkCoordinatesComparedToGrid(GridSize grid, Game game){
		var grid_x = grid.size.x
		var grid_y = grid.size.y

	}
	
	/**
	 * Everyone like to be unique, therefore objects and locations should have unique names.
	 * Furthermore attributes within each object/location should also be unique
	 */
	@Check
	def void checkUniqueName(Declaration declarations) {
		
	}
}
