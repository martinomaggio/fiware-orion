# -*- coding: utf-8 -*-
# Copyright 2015 Telefonica Investigacion y Desarrollo, S.A.U
#
# This file is part of Orion Context Broker.
#
# Orion Context Broker is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Orion Context Broker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
# General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Orion Context Broker. If not, see http://www.gnu.org/licenses/.
#
# For those usages not covered by this license please contact with
# iot_support at tid dot es
# __author__ = 'Jon Calderin Goñi (jon dot caldering at gmail dot com)'

@issue-322
Feature: Service support for registries (NGSI9)
#TODO: Test the subscriptions operation, if service and subservice diference the context provider, when the functionality is defined

  Background:
    Given the Context Broker started with multitenancy


  Scenario: Subscribe different entities with the same provider and subservices but different service
    # First registration
    Given a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
      | Room2     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application |
      | /service1             |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second registration
    And a new "NGSI9" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
      | Room3     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application |
      | /service2             |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Discover
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type | is_pattern |
      | Room.*    | Room        | true       |
    And build the standard discover context availability payload with the previous data
    When a standard disconver context availability is asked with the before information
    Then check the response has the key "id" with the value "Room2"
    And check the response has not the key "id" with the value "Room3"
    And clean the mongo database of the service "issue_322"
    And clean the mongo database of the service "issue_322_2"

  Scenario: Query context of an entity in two context provider with different service
    Given a started mock
    And set the response of the mock in the path "/context_provider/service1/queryContext" as "query_context_response_from_context_provider_xml"
    And set the response of the mock in the path "/context_provider/service2/queryContext" as "query_context_response_from_context_provider_xml"
    # First registration
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service1 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second Registration
    And a new "NGSI9" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service2 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Query consult
    And a new "NGSI10" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard query context payload with the previous data
    When a standard query context is asked with the before information
    #Mock information
    Then retrieve information from the mock
    And the path in the last mock request contains "service2"
    And there is "1" requests sent to the mock
    And  clean the mongo database of the service "issue_322"
    And  clean the mongo database of the service "issue_322_2"

  @update_entity_in_CP
  Scenario: Update an entity in a context provider, having other context provider with the same entity in other service
    Given a started mock
    And set the response of the mock in the path "/context_provider/service1/updateContext" as "update_context_response_from_context_provider_xml"
    And set the response of the mock in the path "/context_provider/service2/updateContext" as "update_context_response_from_context_provider_xml"
    # First registration
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service1 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second Registration
    And a new "NGSI9" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service2 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Update operation
    And a new "NGSI10" api request with the service "issue_322" and the subservice "/subservice"
    And the following attributes to create
      | attribute_name | attribute_type | attribute_value |
      | att1           | att_type_1     | 25              |
    And a context elements with the before attrs and the following entities
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard entity update payload with the previous data
    When a standard context entity update is asked with the before information
    Then retrieve information from the mock
    #Fixme: these steps are comment because the mock is deprecated
    #And the path in the last mock request contains "service1"
    #And there is "1" requests sent to the mock
    And clean the mongo database of the service "issue_322"
    And clean the mongo database of the service "issue_322_2"

  Scenario: Append an entity in a context broker, having context providers with the same entity in the same service and other in other service
    Given a started mock
    # First registration
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service1 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second Registration
    And a new "NGSI9" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service2 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Append operation
    And a new "NGSI10" api request with the service "issue_322" and the subservice "/subservice"
    And the following attributes to create
      | attribute_name | attribute_type | attribute_value |
      | att1           | att_type_1     | 25              |
    And a context elements with the before attrs and the following entities
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard entity creation payload with the previous data
    When a standard context entity creation is asked with the before information
    Then retrieve information from the mock
    And there is "0" requests sent to the mock
    And clean the mongo database of the service "issue_322"
    And clean the mongo database of the service "issue_322_2"

  @issue-755
  Scenario: Delete an entity doesnt exist in context broker (error expected), having context providers with the same entity in the same subservice and other in other subservice
    Given a started mock
    # First registration
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service1 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second Registration
    And a new "NGSI9" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service2 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Delete operation
    And a new "NGSI10" api request with the service "issue_322" and the subservice "/subservice"
    And the following attributes to create
      | attribute_name | attribute_type | attribute_value |
      | att1           | att_type_1     |                 |
    And a context elements with the before attrs and the following entities
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard entity delete payload with the previous data
    When a standard context entity delete is asked with the before information
    Then retrieve information from the mock
    And there is "0" requests sent to the mock
    And clean the mongo database of the service "issue_322"
    And clean the mongo database of the service "issue_322_2"

  Scenario: Entity in CB and in CP with the same service, and in other CP with other service.
    Given a started mock
    # First registration
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service1 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second Registration
    And a new "NGSI9" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service2 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Append operation
    And a new "NGSI10" api request with the service "issue_322" and the subservice "/subservice"
    And the following attributes to create
      | attribute_name | attribute_type | attribute_value |
      | att1           | att_type_1     | 25              |
    And a context elements with the before attrs and the following entities
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard entity creation payload with the previous data
    And a standard context entity creation is asked with the before information
    # Query operation
    And a new "NGSI10" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard query context payload with the previous data
    And a standard query context is asked with the before information
    Then retrieve information from the mock
    And there is "0" requests sent to the mock
    And clean the mongo database of the service "issue_322"
    And clean the mongo database of the service "issue_322_2"

  Scenario: Entity in CB and in CP with the same service, and in other CP with other service.
    Given a started mock
    And set the response of the mock in the path "/context_provider/service1/queryContext" as "query_context_response_from_context_provider_xml"
    And set the response of the mock in the path "/context_provider/service2/queryContext" as "query_context_response_from_context_provider_xml"
    # First registration
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service1 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second Registration
    And a new "NGSI9" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service2 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Append operation
    And a new "NGSI10" api request with the service "issue_322" and the subservice "/subservice"
    And the following attributes to create
      | attribute_name | attribute_type | attribute_value |
      | att1           | att_type_1     | 25              |
    And a context elements with the before attrs and the following entities
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard entity creation payload with the previous data
    And a standard context entity creation is asked with the before information
    # Query operation
    And a new "NGSI10" api request with the service "issue_322_2" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard query context payload with the previous data
    And a standard query context is asked with the before information
    Then retrieve information from the mock
    And there is "1" requests sent to the mock
    And the path in the last mock request contains "service2"
    And clean the mongo database of the service "issue_322"
    And clean the mongo database of the service "issue_322_2"

  @entity_in_CP_without_service
  Scenario: Entity in CB and in CP without service, and in other CP with other service.
    Given a started mock
    And set the response of the mock in the path "/context_provider/service1/queryContext" as "query_context_response_from_context_provider_xml"
    And set the response of the mock in the path "/context_provider/service2/queryContext" as "query_context_response_from_context_provider_xml"
    # First registration
    And a new "NGSI9" api request with the service "empty" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service1 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second Registration
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service2 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Append operation
    And a new "NGSI10" api request with the service "empty" and the subservice "/subservice"
    And the following attributes to create
      | attribute_name | attribute_type | attribute_value |
      | att1           | att_type_1     | 25              |
    And a context elements with the before attrs and the following entities
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard entity creation payload with the previous data
    And a standard context entity creation is asked with the before information
    # Query operation
    And a new "NGSI10" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard query context payload with the previous data
    And a standard query context is asked with the before information
    Then retrieve information from the mock
    #Fixme: these steps are comment because the mock is deprecated
    #And there is "1" requests sent to the mock
    #And the path in the last mock request contains "service2"
    And clean the mongo database of the service "issue_322"
    And clean the mongo database of the service ""

  #entity_in_CP_with_service
  Scenario: Entity in CB and in CP with service, and in other CP without service.
    Given a started mock
    And set the response of the mock in the path "/context_provider/service1/queryContext" as "query_context_response_from_context_provider_xml"
    And set the response of the mock in the path "/context_provider/service2/queryContext" as "query_context_response_from_context_provider_xml"
    # First registration
    And a new "NGSI9" api request with the service "issue_322" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service1 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Second Registration
    And a new "NGSI9" api request with the service "empty" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And the following attributes to consult
      | attribute_name | attribute_type |
      | att1           | att_type_1     |
    And a context registrations with the before entities and attributes and the following providing applications
      | providing_application      |
      | /context_provider/service2 |
    And build the standard context registration payload with the previous data and duration "P1M"
    And a standard context registration is asked with the before information
    # Append operation
    And a new "NGSI10" api request with the service "issue_322" and the subservice "/subservice"
    And the following attributes to create
      | attribute_name | attribute_type | attribute_value |
      | att1           | att_type_1     | 25              |
    And a context elements with the before attrs and the following entities
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard entity creation payload with the previous data
    And a standard context entity creation is asked with the before information
    # Query operation
    And a new "NGSI10" api request with the service "empty" and the subservice "/subservice"
    And the following entities to consult
      | entity_id | entity_type |
      | Room1     | Room        |
    And build the standard query context payload with the previous data
    And a standard query context is asked with the before information
    Then retrieve information from the mock
    #Fixme: these steps are comment because the mock is deprecated
    #And there is "1" requests sent to the mock
    #And the path in the last mock request contains "service2"
    And clean the mongo database of the service "issue_322"
    And clean the mongo database of the service ""
