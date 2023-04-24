/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package Box2D.Dynamics{

import Box2D.Common.Math.*;
import Box2D.Common.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Dynamics.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Dynamics.Joints.*;

import Box2D.Common.b2internal;
use namespace b2internal;


/**
 * A fixture definition is used to create a fixture. This class defines an
 * abstract fixture definition. You can reuse fixture definitions safely.
 */
public class b2FixtureDef
{
	/**
	 * The constructor sets the default fixture definition values.
	 */
	public function b2FixtureDef(shape:b2Shape = null, userData:* = null, friction:Number = 0.2, restitution:Number = 0.0, density:Number = 0.0, categoryBits:uint = 0x0001, maskBits:uint = 0xFFFF, groupIndex:int = 0, isSensor:Boolean = false)
	{
		this.shape = shape;
		this.userData = userData;
		this.friction = friction;
		this.restitution = restitution;
		this.density = density;
		this.filter.categoryBits = categoryBits;
		this.filter.maskBits = maskBits;
		this.filter.groupIndex = groupIndex;
		this.isSensor = isSensor;
	}
	
	/**
	 * The shape, this must be set. The shape will be cloned, so you
	 * can create the shape on the stack.
	 */
	public var shape:b2Shape;

	/**
	 * Use this to store application specific fixture data.
	 */
	public var userData:*;

	/**
	 * The friction coefficient, usually in the range [0,1].
	 */
	public var friction:Number;

	/**
	 * The restitution (elasticity) usually in the range [0,1].
	 */
	public var restitution:Number;

	/**
	 * The density, usually in kg/m^2.
	 */
	public var density:Number;

	/**
	 * A sensor shape collects contact information but never generates a collision
	 * response.
	 */
	public var isSensor:Boolean;

	/**
	 * Contact filtering data.
	 */
	public var filter:b2FilterData = new b2FilterData();
};



}
