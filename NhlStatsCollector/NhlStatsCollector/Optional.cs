using System;
using System.Collections.Generic;

namespace NhlStatsCollector
{
	public sealed class Optional
	{
		public static Optional<T> From<T>(T value) => Optional<T>.From(value);

		public static readonly Optional Empty = new Optional();

		private Optional()
		{
		}
	}

	public struct Optional<T> : IEquatable<Optional<T>>
	{
		private readonly T _value;

		public static Optional<T> Empty => new Optional<T>(false, default(T));

		public static Optional<T> From(T value) => new Optional<T>(value);

		private Optional(T value)
		   : this(true, value)
		{
			if (value == null)
				throw new ArgumentNullException(nameof(value));
		}

		private Optional(bool hasValue, T value)
		{
			HasValue = hasValue;
			_value = value;
		}

		public bool HasValue { get; }

		public bool IsEmpty => !HasValue;

		public T Value
		{
			get
			{
				if (IsEmpty)
					throw new InvalidOperationException("Has no value");

				return _value;
			}
		}

		public static implicit operator Optional<T>(T value) => new Optional<T>(value);

		public static explicit operator T(Optional<T> optional) => optional.Value;

		public static implicit operator Optional<T>(Optional result) => new Optional<T>(false, default(T));

		public bool ReferenceEquals(Optional<T> other)
		{
			if (HasValue != other.HasValue)
				return false;
			if (!HasValue)
				return true;
			return ReferenceEquals(_value, other._value);
		}

		public override bool Equals(object obj) => obj is Optional<T> && Equals((Optional<T>)obj);

		public bool Equals(Optional<T> other) => EqualityComparer<T>.Default.Equals(_value, other._value) && HasValue == other.HasValue;

		public override int GetHashCode()
		{
			return HashCode.Combine(
			   EqualityComparer<T>.Default.GetHashCode(_value),
			   HasValue.GetHashCode());
		}

		public static bool operator ==(Optional<T> optional1, Optional<T> optional2) => optional1.Equals(optional2);

		public static bool operator !=(Optional<T> optional1, Optional<T> optional2) => !(optional1 == optional2);

		public override string ToString()
		{
			if (IsEmpty)
				return "<null>";
			return _value.ToString();
		}
	}
}
