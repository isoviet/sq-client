package landing.sensors
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;

	public interface ISensor
	{
		function beginContact(contact:b2Contact):void;
		function endContact(contact:b2Contact):void;
		function preSolve(contact:b2Contact, oldManifold:b2Manifold):void;
		function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void;
	}
}