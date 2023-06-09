﻿package dragonBones.animation
{
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	import dragonBones.Bone;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.TransformFrame;
	import dragonBones.objects.TransformTimeline;
	import dragonBones.utils.TransformUtil;

	use namespace dragonBones_internal;

	/** @private */
	public final class TimelineState
	{
		private static const HALF_PI:Number = Math.PI * 0.5;
		private static const DOUBLE_PI:Number = Math.PI * 2;

		private static var _pool:Vector.<TimelineState> = new Vector.<TimelineState>;

		/** @private */
		dragonBones_internal static function borrowObject():TimelineState
		{
			if(_pool.length == 0)
			{
				return new TimelineState();
			}
			return _pool.pop();
		}

		/** @private */
		dragonBones_internal static function returnObject(timeline:TimelineState):void
		{
			if(_pool.indexOf(timeline) < 0)
			{
				_pool[_pool.length] = timeline;
			}

			timeline.clear();
		}

		/** @private */
		dragonBones_internal static function clear():void
		{
			var i:int = _pool.length;
			while(i --)
			{
				_pool[i].clear();
			}
			_pool.length = 0;
		}

		public static function getEaseValue(value:Number, easing:Number):Number
		{
			if (easing > 1)
			{
				var valueEase:Number = 0.5 * (1 - Math.cos(value * Math.PI )) - value;
				easing -= 1;
			}
			else if (easing > 0)
			{
				valueEase = Math.sin(value * HALF_PI) - value;
			}
			else if (easing < 0)
			{
				valueEase = 1 - Math.cos(value * HALF_PI) - value;
				easing *= -1;
			}
			return valueEase * easing + value;
		}

		public var transform:DBTransform;
		public var pivot:Point;
		public var tweenActive:Boolean;

		private var _updateState:int;

		private var _animationState:AnimationState;
		private var _bone:Bone;
		private var _timeline:TransformTimeline;
		private var _currentFrame:TransformFrame;
		private var _currentFramePosition:Number;
		private var _currentFrameDuration:Number;
		private var _durationTransform:DBTransform;
		private var _durationPivot:Point;
		private var _durationColor:ColorTransform;
		private var _originTransform:DBTransform;
		private var _originPivot:Point;

		private var _tweenEasing:Number;
		private var _tweenTransform:Boolean;
		private var _tweenColor:Boolean;

		private var _totalTime:Number;

		public function TimelineState()
		{
			transform = new DBTransform();
			pivot = new Point();

			//_originTransform = new DBTransform();

			_durationTransform = new DBTransform();
			_durationPivot = new Point();
			_durationColor = new ColorTransform();
		}

		public function fadeIn(bone:Bone, animationState:AnimationState, timeline:TransformTimeline):void
		{
			_bone = bone;
			_animationState = animationState;
			_timeline = timeline;

			_originTransform = _timeline.originTransform;
			_originPivot = _timeline.originPivot;
			//_originTransform.copy(_timeline.originTransform);

			/*
			var bLRX:Number = _bone.origin.skewX + _bone.offset.skewX + _bone._tween.skewX;
			var bLRY:Number = _bone.origin.skewY + _bone.offset.skewY + _bone._tween.skewY;

			_originTransform.skewX = bLRX + TransformUtils.formatRadian(_originTransform.skewX - bLRX);
			_originTransform.skewY = bLRY + TransformUtils.formatRadian(_originTransform.skewY - bLRY);
			*/

			_tweenTransform = false;
			_tweenColor = false;

			_totalTime = _animationState.totalTime;

			transform.x = 0;
			transform.y = 0;
			transform.scaleX = 0;
			transform.scaleY = 0;
			transform.skewX = 0;
			transform.skewY = 0;
			pivot.x = 0;
			pivot.y = 0;

			_durationTransform.x = 0;
			_durationTransform.y = 0;
			_durationTransform.scaleX = 0;
			_durationTransform.scaleY = 0;
			_durationTransform.skewX = 0;
			_durationTransform.skewY = 0;
			_durationPivot.x = 0;
			_durationPivot.y = 0;

			_currentFrame = null;

			switch(_timeline.frameList.length)
			{
				case 0:
					_bone.arriveAtFrame(null, this, _animationState, false);
					_updateState = 0;
					break;
				case 1:
					_updateState = -1;
					break;
				default:
					_updateState = 1;
					break;
			}
		}

		public function fadeOut():void
		{
			transform.skewX = TransformUtil.formatRadian(transform.skewX);
			transform.skewY = TransformUtil.formatRadian(transform.skewY);
			//_originTransform.skewX = TransformUtil.formatRadian(_originTransform.skewX);
			//_originTransform.skewY = TransformUtil.formatRadian(_originTransform.skewY);
		}

		public function update(progress:Number):void
		{
			if(_updateState)
			{
				if(_updateState > 0)
				{
					if(_timeline.scale == 0)
					{
						progress = 1;
					}
					else
					{
						progress /= _timeline.scale;
					}

					if(progress == 1)
					{
						progress = 0.99999999;
					}

					progress += _timeline.offset;
					var loopCount:int = progress;
					progress -= loopCount;

					//
					var playedTime:Number = _totalTime * progress;
					var isArrivedFrame:Boolean = false;
					var frameIndex:int;
					while (!_currentFrame || playedTime > _currentFramePosition + _currentFrameDuration || playedTime < _currentFramePosition)
					{
						if(isArrivedFrame)
						{
							_bone.arriveAtFrame(_currentFrame, this, _animationState, true);
						}
						isArrivedFrame = true;
						if(_currentFrame)
						{
							frameIndex = _timeline.frameList.indexOf(_currentFrame) + 1;
							if(frameIndex >= _timeline.frameList.length)
							{
								frameIndex = 0;
							}
							_currentFrame = _timeline.frameList[frameIndex] as TransformFrame;
						}
						else
						{
							frameIndex = 0;
							_currentFrame = _timeline.frameList[0] as TransformFrame;
						}
						_currentFrameDuration = _currentFrame.duration;
						_currentFramePosition = _currentFrame.position;
					}

					if(isArrivedFrame)
					{
						tweenActive = _currentFrame.displayIndex >= 0;
						frameIndex ++;
						if(frameIndex >= _timeline.frameList.length)
						{
							frameIndex = 0;
						}
						var nextFrame:TransformFrame = _timeline.frameList[frameIndex] as TransformFrame;

						if(
							frameIndex == 0 &&
							_animationState.loop &&
							_animationState.loopCount >= Math.abs(_animationState.loop) - 1 &&
							((_currentFramePosition + _currentFrameDuration) / _totalTime + loopCount - _timeline.offset) * _timeline.scale > 0.99999999
						)
						{
							_updateState = 0;
							_tweenEasing = NaN;
						}
						else if(_currentFrame.displayIndex < 0 || nextFrame.displayIndex < 0 || !_animationState.tweenEnabled)
						{
							_tweenEasing = NaN;
						}
						else if(isNaN(_animationState.clip.tweenEasing))
						{
							_tweenEasing = _currentFrame.tweenEasing;
						}
						else
						{
							_tweenEasing = _animationState.clip.tweenEasing;
						}

						if(isNaN(_tweenEasing))
						{
							_tweenTransform = false;
							_tweenColor = false;
						}
						else
						{
							_durationTransform.x = nextFrame.transform.x - _currentFrame.transform.x;
							_durationTransform.y = nextFrame.transform.y - _currentFrame.transform.y;
							_durationTransform.skewX = nextFrame.transform.skewX - _currentFrame.transform.skewX;
							_durationTransform.skewY = nextFrame.transform.skewY - _currentFrame.transform.skewY;
							_durationTransform.scaleX = nextFrame.transform.scaleX - _currentFrame.transform.scaleX;
							_durationTransform.scaleY = nextFrame.transform.scaleY - _currentFrame.transform.scaleY;

							if(frameIndex == 0)
							{
								_durationTransform.skewX = TransformUtil.formatRadian(_durationTransform.skewX);
								_durationTransform.skewY = TransformUtil.formatRadian(_durationTransform.skewY);
							}

							_durationPivot.x = nextFrame.pivot.x - _currentFrame.pivot.x;
							_durationPivot.y = nextFrame.pivot.y - _currentFrame.pivot.y;

							if(
								_durationTransform.x != 0 ||
								_durationTransform.y != 0 ||
								_durationTransform.skewX != 0 ||
								_durationTransform.skewY != 0 ||
								_durationTransform.scaleX != 0 ||
								_durationTransform.scaleY != 0 ||
								_durationPivot.x != 0 ||
								_durationPivot.y != 0
							)
							{
								_tweenTransform = true;
							}
							else
							{
								_tweenTransform = false;
							}

							if(_currentFrame.color && nextFrame.color)
							{
								_durationColor.alphaOffset = nextFrame.color.alphaOffset - _currentFrame.color.alphaOffset;
								_durationColor.redOffset = nextFrame.color.redOffset - _currentFrame.color.redOffset;
								_durationColor.greenOffset = nextFrame.color.greenOffset - _currentFrame.color.greenOffset;
								_durationColor.blueOffset = nextFrame.color.blueOffset - _currentFrame.color.blueOffset;

								_durationColor.alphaMultiplier = nextFrame.color.alphaMultiplier - _currentFrame.color.alphaMultiplier;
								_durationColor.redMultiplier = nextFrame.color.redMultiplier - _currentFrame.color.redMultiplier;
								_durationColor.greenMultiplier = nextFrame.color.greenMultiplier - _currentFrame.color.greenMultiplier;
								_durationColor.blueMultiplier = nextFrame.color.blueMultiplier - _currentFrame.color.blueMultiplier;

								if(
									_durationColor.alphaOffset != 0 ||
									_durationColor.redOffset != 0 ||
									_durationColor.greenOffset != 0 ||
									_durationColor.blueOffset != 0 ||
									_durationColor.alphaMultiplier != 0 ||
									_durationColor.redMultiplier != 0 ||
									_durationColor.greenMultiplier != 0 ||
									_durationColor.blueMultiplier != 0
								)
								{
									_tweenColor = true;
								}
								else
								{
									_tweenColor = false;
								}
							}
							else if(_currentFrame.color)
							{
								_tweenColor = true;
								_durationColor.alphaOffset = -_currentFrame.color.alphaOffset;
								_durationColor.redOffset = -_currentFrame.color.redOffset;
								_durationColor.greenOffset = -_currentFrame.color.greenOffset;
								_durationColor.blueOffset = -_currentFrame.color.blueOffset;

								_durationColor.alphaMultiplier = 1 - _currentFrame.color.alphaMultiplier;
								_durationColor.redMultiplier = 1 - _currentFrame.color.redMultiplier;
								_durationColor.greenMultiplier = 1 - _currentFrame.color.greenMultiplier;
								_durationColor.blueMultiplier = 1 - _currentFrame.color.blueMultiplier;
							}
							else if(nextFrame.color)
							{
								_tweenColor = true;
								_durationColor.alphaOffset = nextFrame.color.alphaOffset;
								_durationColor.redOffset = nextFrame.color.redOffset;
								_durationColor.greenOffset = nextFrame.color.greenOffset;
								_durationColor.blueOffset = nextFrame.color.blueOffset;

								_durationColor.alphaMultiplier = nextFrame.color.alphaMultiplier - 1;
								_durationColor.redMultiplier = nextFrame.color.redMultiplier - 1;
								_durationColor.greenMultiplier = nextFrame.color.greenMultiplier - 1;
								_durationColor.blueMultiplier = nextFrame.color.blueMultiplier - 1;
							}
							else
							{
								_tweenColor = false;
							}
						}

						if(!_tweenTransform)
						{
							if(_animationState.blend)
							{
								transform.x = _originTransform.x + _currentFrame.transform.x;
								transform.y = _originTransform.y + _currentFrame.transform.y;
								transform.skewX = _originTransform.skewX + _currentFrame.transform.skewX;
								transform.skewY = _originTransform.skewY + _currentFrame.transform.skewY;
								transform.scaleX = _originTransform.scaleX + _currentFrame.transform.scaleX;
								transform.scaleY = _originTransform.scaleY + _currentFrame.transform.scaleY;

								pivot.x = _originPivot.x + _currentFrame.pivot.x;
								pivot.y = _originPivot.y + _currentFrame.pivot.y;
							}
							else
							{
								transform.x = _currentFrame.transform.x;
								transform.y = _currentFrame.transform.y;
								transform.skewX = _currentFrame.transform.skewX;
								transform.skewY = _currentFrame.transform.skewY;
								transform.scaleX = _currentFrame.transform.scaleX;
								transform.scaleY = _currentFrame.transform.scaleY;

								pivot.x = _currentFrame.pivot.x;
								pivot.y = _currentFrame.pivot.y;
							}
						}

						if(!_tweenColor)
						{
							if(_currentFrame.color)
							{
								_bone.updateColor(
									_currentFrame.color.alphaOffset,
									_currentFrame.color.redOffset,
									_currentFrame.color.greenOffset,
									_currentFrame.color.blueOffset,
									_currentFrame.color.alphaMultiplier,
									_currentFrame.color.redMultiplier,
									_currentFrame.color.greenMultiplier,
									_currentFrame.color.blueMultiplier,
									true
								);
							}
							else if(_bone._isColorChanged)
							{
								_bone.updateColor(0, 0, 0, 0, 1, 1, 1, 1, false);
							}
						}
						_bone.arriveAtFrame(_currentFrame, this, _animationState, false);
					}

					if(_tweenTransform || _tweenColor)
					{
						progress = (playedTime - _currentFramePosition) / _currentFrameDuration;
						if(_tweenEasing)
						{
							progress = getEaseValue(progress, _tweenEasing);
						}
					}

					if(_tweenTransform)
					{
						var currentTransform:DBTransform = _currentFrame.transform;
						var currentPivot:Point = _currentFrame.pivot;
						if(_animationState.blend)
						{
							transform.x = _originTransform.x + currentTransform.x + _durationTransform.x * progress;
							transform.y = _originTransform.y + currentTransform.y + _durationTransform.y * progress;
							transform.skewX = _originTransform.skewX + currentTransform.skewX + _durationTransform.skewX * progress;
							transform.skewY = _originTransform.skewY + currentTransform.skewY + _durationTransform.skewY * progress;
							transform.scaleX = _originTransform.scaleX + currentTransform.scaleX + _durationTransform.scaleX * progress;
							transform.scaleY = _originTransform.scaleY + currentTransform.scaleY + _durationTransform.scaleY * progress;

							pivot.x = _originPivot.x + currentPivot.x + _durationPivot.x * progress;
							pivot.y = _originPivot.y + currentPivot.y + _durationPivot.y * progress;
						}
						else
						{
							transform.x = currentTransform.x + _durationTransform.x * progress;
							transform.y = currentTransform.y + _durationTransform.y * progress;
							transform.skewX = currentTransform.skewX + _durationTransform.skewX * progress;
							transform.skewY = currentTransform.skewY + _durationTransform.skewY * progress;
							transform.scaleX = currentTransform.scaleX + _durationTransform.scaleX * progress;
							transform.scaleY = currentTransform.scaleY + _durationTransform.scaleY * progress;

							pivot.x = currentPivot.x + _durationPivot.x * progress;
							pivot.y = currentPivot.y + _durationPivot.y * progress;
						}
					}

					if(_tweenColor)
					{
						if(_currentFrame.color)
						{
							_bone.updateColor(
								_currentFrame.color.alphaOffset + _durationColor.alphaOffset * progress,
								_currentFrame.color.redOffset + _durationColor.redOffset * progress,
								_currentFrame.color.greenOffset + _durationColor.greenOffset * progress,
								_currentFrame.color.blueOffset + _durationColor.blueOffset * progress,
								_currentFrame.color.alphaMultiplier + _durationColor.alphaMultiplier * progress,
								_currentFrame.color.redMultiplier + _durationColor.redMultiplier * progress,
								_currentFrame.color.greenMultiplier + _durationColor.greenMultiplier * progress,
								_currentFrame.color.blueMultiplier + _durationColor.blueMultiplier * progress,
								true
							);
						}
						else
						{
							_bone.updateColor(
								_durationColor.alphaOffset * progress,
								_durationColor.redOffset * progress,
								_durationColor.greenOffset * progress,
								_durationColor.blueOffset * progress,
								1 + _durationColor.alphaMultiplier * progress,
								1 + _durationColor.redMultiplier * progress,
								1 + _durationColor.greenMultiplier * progress,
								1 + _durationColor.blueMultiplier * progress,
								true
							);
						}
					}
				}
				else
				{
					_updateState = 0;
					if(_animationState.blend)
					{
						transform.copy(_originTransform);

						pivot.x = _originPivot.x;
						pivot.y = _originPivot.y;
					}
					else
					{
						transform.x =
							transform.y =
							transform.skewX =
							transform.skewY =
							transform.scaleX =
							transform.scaleY = 0;

						pivot.x = 0;
						pivot.y = 0;
					}

					_currentFrame = _timeline.frameList[0] as TransformFrame;

					tweenActive = _currentFrame.displayIndex >= 0;

					if(_currentFrame.color)
					{
						_bone.updateColor(
							_currentFrame.color.alphaOffset,
							_currentFrame.color.redOffset,
							_currentFrame.color.greenOffset,
							_currentFrame.color.blueOffset,
							_currentFrame.color.alphaMultiplier,
							_currentFrame.color.redMultiplier,
							_currentFrame.color.greenMultiplier,
							_currentFrame.color.blueMultiplier,
							true
						);
					}
					else
					{
						_bone.updateColor(0, 0, 0, 0, 1, 1, 1, 1, false);
					}

					_bone.arriveAtFrame(_currentFrame, this, _animationState, false);
				}
			}
		}

		private function clear():void
		{
			_updateState = 0;
			_bone = null;
			_animationState = null;
			_timeline = null;
			_currentFrame = null;
			_originTransform = null;
			_originPivot = null;
		}
	}
}