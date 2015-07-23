package org.eclipse.vorto.codegen.examples.webdevicegenerator.tasks.templates

import java.util.HashSet
import java.util.Set
import org.eclipse.vorto.codegen.api.tasks.ITemplate
import org.eclipse.vorto.codegen.examples.webdevicegenerator.tasks.ModuleUtil
import org.eclipse.vorto.core.api.model.datatype.Entity
import org.eclipse.vorto.core.api.model.datatype.Enum
import org.eclipse.vorto.core.api.model.datatype.ObjectPropertyType
import org.eclipse.vorto.core.api.model.datatype.PrimitivePropertyType

class EntityClassTemplate implements ITemplate<Entity> {
		
	override getContent(Entity entity) {
		return '''
		package «ModuleUtil.getEntityPackage(entity)»;
		
		import org.codehaus.jackson.map.annotate.JsonSerialize;
		«getImportsContent(entity)»
		
		@JsonSerialize
		public class «entity.name» {	
			«getPropertiesContent(entity)»
			«getSettersGettersContent(entity)»
		}
		'''
	}
	
	def getImportsContent(Entity entity) {
		var Set<String> imports = new HashSet<String>
		for (property : entity.properties) {
			if (property.type instanceof ObjectPropertyType) {
				var objectType =(property.type as ObjectPropertyType).type
				if (objectType instanceof Entity) {
					imports.add("import " + ModuleUtil.getEntityPackage(objectType as Entity)+ "." + objectType.name+";")
				}
				else if (objectType instanceof Enum) {
					imports.add("import " + ModuleUtil.getEnumPackage(objectType as Enum)+"."+objectType.name+";")
				}
			}
		}
		'''
		«FOR i : imports»
			«i»
		«ENDFOR»
		'''
	}
	
	
	def getPropertiesContent(Entity entity) {
		'''
		«FOR  property : entity.properties»	
				«IF property.type instanceof PrimitivePropertyType»
					«var primitiveType =(property.type as PrimitivePropertyType).type»
					«var primitiveJavaType = PropertyUtil.toJavaFieldType(primitiveType)»
					private «primitiveJavaType» «property.name» = «PropertyUtil.getDefaultValue(primitiveType)»;
				«ENDIF»
				«IF property.type instanceof ObjectPropertyType»
					«var objectType =(property.type as ObjectPropertyType).type»
					«IF objectType instanceof Entity»
						private «(objectType as Entity).name» «property.name» = new «(objectType as Entity).name»();	
					«ELSEIF objectType instanceof Enum»
						private «(objectType as Enum).name» «property.name»;
					«ENDIF»
				«ENDIF»
			«ENDFOR»
		'''
	}
	
	def getSettersGettersContent(Entity entity) {
		'''
		
		«FOR  property : entity.properties»	
				«IF property.type instanceof PrimitivePropertyType»
					«var primitiveType =(property.type as PrimitivePropertyType).type»
					«var primitiveJavaType = PropertyUtil.toJavaFieldType(primitiveType)»
					public «primitiveJavaType» get«property.name.toFirstUpper»() {
						return «property.name»;
					}
							
					public void set«property.name.toFirstUpper»(«primitiveJavaType» «property.name») {
						this.«property.name» = «property.name»;
					}
					
				«ENDIF»
				«IF property.type instanceof ObjectPropertyType»
					«var objectType =(property.type as ObjectPropertyType).type»
					«IF objectType instanceof Entity»
							public «(objectType as Entity).name» get«property.name.toFirstUpper»() {
								return «property.name»;
							}
								
							public void set«property.name.toFirstUpper»(«(objectType as Entity).name» «property.name») {
								this.«property.name» = «property.name»;
							}
							
						«ELSEIF objectType instanceof Enum»
							public «(objectType as Enum).name» get«property.name.toFirstUpper»() {
								return «property.name»;
							}
								
							public void set«property.name.toFirstUpper»(«(objectType as Enum).name» «property.name») {
								this.«property.name» = «property.name»;
							}
							
					«ENDIF»
				«ENDIF»
		«ENDFOR»
		'''
	}
}