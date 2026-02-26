struct Node<T> {
  value: T,
  next: Option<Box<Node<T>>>,
}

impl<T> Node<T> {
  fn new(value: T) -> Self {
    Node { value, next: None }
  }

  fn push(&mut self, value: T) {
    match self.next {
      Some(ref mut next) => next.push(value),
      None => self.next = Some(Box::new(Node::new(value))),
    }
  }
}
