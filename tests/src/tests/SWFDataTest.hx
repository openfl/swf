package tests;

import swf.SWFData;
import swf.data.SWFColorTransformWithAlpha;
import swf.data.SWFMatrix;
import swf.data.SWFRectangle;
import utest.Assert;
import utest.Test;

class SWFDataTest extends Test
{
	public function testCalculateMaxBits():Void
	{
		var data = new SWFData();
		Assert.equals(0, data.calculateMaxBits(false, [0]));
		Assert.equals(1, data.calculateMaxBits(false, [1]));
		Assert.equals(8, data.calculateMaxBits(false, [255]));
		Assert.equals(10, data.calculateMaxBits(false, [1000]));
		Assert.equals(0, data.calculateMaxBits(true, [0, 0]));
		Assert.equals(2, data.calculateMaxBits(true, [1]));
		Assert.equals(1, data.calculateMaxBits(true, [-1, 0]));
		Assert.equals(2, data.calculateMaxBits(true, [-2]));
		Assert.equals(12, data.calculateMaxBits(true, [2047, -2048]));
		Assert.equals(13, data.calculateMaxBits(true, [2048, 0]));
		Assert.equals(13, data.calculateMaxBits(true, [0, -2049]));
	}

	public function testMatrixRoundTrip():Void
	{
		var matrix = new SWFMatrix();
		matrix.scaleX = 1.5;
		matrix.scaleY = 0.5;
		matrix.rotateSkew0 = 0.25;
		matrix.rotateSkew1 = -0.25;
		matrix.translateX = 2000;
		matrix.translateY = -3000;

		var data = new SWFData();
		data.writeMATRIX(matrix);
		data.position = 0;
		Assert.equals(matrix.toString(), data.readMATRIX().toString());

		var translation = new SWFMatrix();
		translation.translateX = -1;
		data = new SWFData();
		data.writeMATRIX(translation);
		data.position = 0;
		Assert.equals(translation.toString(), data.readMATRIX().toString());
	}

	public function testRectangleRoundTrip():Void
	{
		var rect = new SWFRectangle();
		rect.xmin = -20;
		rect.xmax = 11000;
		rect.ymin = 0;
		rect.ymax = 8000;

		var data = new SWFData();
		data.writeRECT(rect);
		data.position = 0;
		var result = data.readRECT();
		Assert.equals(-20, result.xmin);
		Assert.equals(11000, result.xmax);
		Assert.equals(0, result.ymin);
		Assert.equals(8000, result.ymax);
	}

	public function testColorTransformRoundTrip():Void
	{
		var colorTransform = new SWFColorTransformWithAlpha();
		colorTransform.hasMultTerms = true;
		colorTransform.hasAddTerms = true;
		colorTransform.rMult = 256;
		colorTransform.gMult = 128;
		colorTransform.bMult = 0;
		colorTransform.aMult = 256;
		colorTransform.rAdd = -255;
		colorTransform.gAdd = 255;
		colorTransform.bAdd = 0;
		colorTransform.aAdd = 0;

		var data = new SWFData();
		data.writeCXFORMWITHALPHA(colorTransform);
		data.position = 0;
		var result = data.readCXFORMWITHALPHA();
		Assert.equals(256, result.rMult);
		Assert.equals(128, result.gMult);
		Assert.equals(0, result.bMult);
		Assert.equals(256, result.aMult);
		Assert.equals(-255, result.rAdd);
		Assert.equals(255, result.gAdd);
		Assert.equals(0, result.bAdd);
		Assert.equals(0, result.aAdd);
	}
}
