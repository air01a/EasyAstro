from ..models.image import Image

def stack_image(image: Image, stack : Image, num : int, stacking_method : int = 0):
        """
        Compute stacking according to user defined stacking mode
        the image data is modified in place by this function
        :param image: the image to be stacked
        :type image: Image
        """

        if stacking_method == 0:
            stack.data = image.data + stack.data
        elif stacking_method == 1:
            stack.data = (num * stack.data + image.data) / (1 + num)