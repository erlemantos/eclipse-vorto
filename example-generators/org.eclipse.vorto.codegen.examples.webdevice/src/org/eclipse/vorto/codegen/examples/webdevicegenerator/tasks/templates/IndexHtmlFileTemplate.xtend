/*******************************************************************************
 * Copyright (c) 2014 Bosch Software Innovations GmbH and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * The Eclipse Distribution License is available at
 * http://www.eclipse.org/org/documents/edl-v10.php.
 *
 * Contributors:
 * Bosch Software Innovations GmbH - Please refer to git log
 *
 *******************************************************************************/
 package org.eclipse.vorto.codegen.examples.webdevicegenerator.tasks.templates

import org.eclipse.vorto.codegen.api.tasks.ITemplate
import org.eclipse.vorto.core.api.model.datatype.PrimitivePropertyType
import org.eclipse.vorto.core.api.model.informationmodel.FunctionblockProperty
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.core.api.model.datatype.ObjectPropertyType
import org.eclipse.vorto.core.api.model.datatype.Property
import org.eclipse.emf.common.util.EList
import org.eclipse.vorto.core.api.model.datatype.Entity
import org.eclipse.vorto.core.api.model.datatype.Enum

class IndexHtmlFileTemplate implements ITemplate<InformationModel> {
			
	override getContent(InformationModel informationModel) {
		return '''
		<html>
		<head>
			<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.2/themes/smoothness/jquery-ui.css">
			<link rel="stylesheet" href="css/webdevice.css">
			<script src="http://code.jquery.com/jquery-2.1.1.min.js"></script>
			<script src="http://code.jquery.com/ui/1.10.2/jquery-ui.min.js"></script>		
			<script src="script/webdevice.js"></script>				
			<script>
				$(function() {
					$( "#tabs" ).tabs();
					«FOR fbModelProperty: informationModel.properties»
					displayProperties("«fbModelProperty.name»");	
					«ENDFOR»
				});
			</script>						
		</head>
		<body>
			<table border="0" align="center" width="75%">
				<tr>
					<td>
						<fieldset id="device_meta">
							<legend>Device Information:</legend>
							<table border="0" align="center" width="100%">
								<tr>
									<td  width="20%"><label>Device Name:</label></td>
									<td width="30%"><label id="device_name" class="display">«informationModel.displayname»</label></td>
									<td  width="20%"><label>Description:</label></td>
									<td width="30%"><label id="device_description" class="display">«informationModel.description»</label></td>
								</tr>
								<tr>
									<td  width="20%"><label>Serial No.</label></td>
									<td width="30%"><label id="device_id" class="display">«informationModel.name»-12345</label></td>
									<td  width="20%"><label>Manufacturer:</label></td>
									<td width="30%"><label id="device_manufacturer" class="display">«informationModel.namespace»</label></td>
								</tr>
								<tr>
									<td  width="20%"><label>Owner</label></td>
									<td width="30%"><label id="device_owner" class="display">admin</label></td>
									<td  width="20%"><label>Registration Date:</label></td>
									<td width="30%"><label id="device_regitration_date" class="display">2015-02-27</label></td>
								</tr>								
							</table>
						</fieldset>
					</td>
				</tr>				
			</table>
			<table border="0" align="center" width="75%">
			    <tr><td>			
				<div id="tabs">
					<ul>
						«FOR fbModelProp: informationModel.properties»
							<li><a href="#functionblocktab-«fbModelProp.name.toLowerCase»">«fbModelProp.name»</a></li>
						«ENDFOR»
					</ul>
					«FOR fbModelProp: informationModel.properties»
						<div id="functionblocktab-«fbModelProp.name.toLowerCase»">	
						    «getFunctionBlockContent(informationModel, fbModelProp)»		
						</div>
					«ENDFOR»
				</div>		
			</td></tr></table>			
		</body>
		</html>
		'''		
	}	
	
	def getFunctionBlockContent(InformationModel informationModel, FunctionblockProperty fbProperty) {
		return '''<table border="0" align="center" width="100%">
				<tr>
					<td align="center">
					«FOR operation : fbProperty.type.functionblock.operations»
						&nbsp;<button type="button" value="«operation.name»" title="«operation.description»" onClick="javascript:invokeOperation('«fbProperty.name»', '«operation.name»')">«WordSeperator.splitIntoWords(operation.name)»</button>&nbsp;
					«ENDFOR»
					</td>
				</tr>				
				<tr>
					<td>
						<fieldset id="«fbProperty.name»_status_fieldset">
							<legend>Status:</legend>
							«IF  fbProperty.type.functionblock.status!=null && fbProperty.type.functionblock.status.properties.size>0»
								«getPropertyContent(fbProperty.name + "_status_id_", fbProperty.type.functionblock.status.properties,false)»
							«ELSE»
							<div class="column">
								<label>No status information is available</label>
							</div>
							«ENDIF»							
						</fieldset>
					</td>
				</tr>
				<tr>
					<td>
						<fieldset id="«fbProperty.name»_configuration_fieldset">
							<legend>Configuration:</legend>
							«IF fbProperty.type.functionblock.configuration!=null && fbProperty.type.functionblock.configuration.properties.size>0»
							<table border="0" align="center" width="100%">
								«var i=0»
								«FOR configuration : fbProperty.type.functionblock.configuration.properties»
								«IF configuration.type instanceof PrimitivePropertyType»
								«IF i%2==0»
									<tr>
								«ENDIF»
									<td  width="20%"><label>«WordSeperator.splitIntoWords(configuration.name)»:</label></td>
									<td width="30%"><input type="text" name="«fbProperty.name»_configuration_id_«configuration.name»" id="«fbProperty.name»_configuration_id_«configuration.name»">
									«IF  (i==fbProperty.type.functionblock.configuration.properties.size-1) && (fbProperty.type.functionblock.configuration.properties.size%2==1)»
											<td  width="20%"><label></td>
											<td  width="30%"><label></td>
										</tr>
									«ENDIF»
								«IF i++%2==1»
									</tr>
								«ENDIF»
								«ENDIF»
								«ENDFOR»
								<tr>
								<td  width="20%"></td>
								<td width="30%">
								</td>
								<td  width="20%">
								
								</td>
								<td width="30%" align="right">
									<button type="button" value="setR" title="" onClick="javascript:saveConfiguration('«fbProperty.name»')">Save</button>
								</td>												
								</td>
							</tr>								
							</table>
							«ELSE»
							<div class="column">
								<label>No configuration information is available</label>
							</div>
							«ENDIF»
						</fieldset>
					</td>
				</tr>				
				<tr>
					<td>
						<fieldset id="«fbProperty.name»_fault_fieldset">
							<legend>Fault:</legend>
							«IF  fbProperty.type.functionblock.fault!=null && fbProperty.type.functionblock.fault.properties.size>0»
								«getPropertyContent(fbProperty.name + "_fault_id_", fbProperty.type.functionblock.fault.properties, false)»
							«ELSE»
							<div class="column">
								<label>No fault information is available</label>
							</div>
							«ENDIF»								
						</fieldset>
					</td>
				</tr>
			</table>
			<table border="0" width="100%" cellpadding="0" cellspacing="0" class="event">
				<tr>
					<th align="center">Event Id</th>
					<th align="center">Type</th>
					<th align="center">Priority</th>
					<th align="center">Date Time</th>
					<th align="center">Details</th>
				</tr>	
				<tr>
					<td align="center">1</td>
					<td align="center">Device Detected</td>
					<td align="center">30</td>
					<td align="center">2015-02-27 10:10:02</td>
					<td align="center">New «fbProperty.type.name» function block instance detected.</td>
				</tr>	
				«var i=2»
				«FOR event : fbProperty.type.functionblock.events»
				<tr>
					<td align="center">«i++»</td>
					<td align="center">«event.name»</td>
					<td align="center">20</td>
					<td align="center">2015-02-27 10:10:25</td>
					<td align="center">XXXX XXX XXX</td>
				</tr>				
				«ENDFOR»										
			</table>			
			'''		
	}
	
	def String getPropertyContent(String prefix, EList<Property> properties, boolean inputAllowed) {
		'''
		<table border="0" align="center" width="100%">
			«var i=0»
			«FOR property : properties»
				«IF property.type instanceof PrimitivePropertyType»
					«IF i%2==0»
						<tr>
					«ENDIF»
					<td  width="20%"><label>«WordSeperator.splitIntoWords(property.name)»:</label></td>
					«IF inputAllowed»
						<td width="30%"><input type="text" name="«prefix»«property.name»" id="«prefix»«property.name»">
					«ELSE»
						<td width="30%"><label id="«prefix»«property.name»" class="display"></label></td>
					«ENDIF»
					«IF (i==properties.size-1) && (properties.size%2==1)»
						<td  width="20%"><label></td>
						<td  width="30%"><label></td>
						</tr>
					«ENDIF»
					«IF i++%2==1»
						</tr>
					«ENDIF»
				«ELSEIF property.type instanceof ObjectPropertyType»
					«var objectType = property.type as ObjectPropertyType»
					«IF objectType.type instanceof Entity»
						<tr>
							<td width="80%">
								<fieldset id="«prefix»«property.name»">
									<legend>«property.name»</legend>
									«getPropertyContent(prefix+property.name+"_", (objectType.type as Entity).properties, inputAllowed) as String»
								</fieldset>
							</td>
						</tr>
					«ELSEIF objectType.type instanceof Enum»
						<tr>
							<td  width="20%"><label>«WordSeperator.splitIntoWords(property.name)»:</label></td>
							<td width="30%"><label id="«prefix»«property.name»" class="display"></label></td>
						</tr>
					«ENDIF»			
				«ENDIF»	
			«ENDFOR»
		</table>'''
	}
}
